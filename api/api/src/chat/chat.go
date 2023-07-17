// Package chat implements a chat service.
//
// Clients subscribe to a chat room by establishing a WebSocket connection.
// Redis is used as the backend, to store and publish messages to any instance
// of this chat service.
//
// Since headers are not supported in the WebSocket handshake, authentication is
// achieved via a temporary token. The token encodes the client and room IDs,
// and should be decoded and validated before upgrading the connection.
package chat

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strings"
	"sync"
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/util/logger"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/random"
	"github.com/go-redis/redis/v8"
	"github.com/gobwas/ws"
	"github.com/gobwas/ws/wsutil"
	"github.com/google/uuid"
	"golang.org/x/time/rate"
)

var (
	// RedisMsgChName is the name of the PubSub channel used to announce new
	// messages to all instances of the chat server.
	RedisMsgChName = "chat-messages-channel"

	// PublishChBufferSize is the buffer size of the channel used to send
	// messages to the client.
	PublishChBufferSize = 16

	// ClientChBufferSize is the buffer size of the channel used to transmit
	// messages sent by the client to the handler.
	ClientChBufferSize = 16

	// ErrChBufferSize is the buffer size of the channel used to send error
	// messages to the client.
	ErrChBufferSize = 16

	TempAuthTokenLength = 32
	TempAuthTokenTTL    = time.Minute

	SubscriberRateLimit    = rate.Limit(10)
	SubscriberLimiterBurst = 8

	PostRateLimit       = rate.Limit(10)
	PostLimiterBurst    = 8
	ErrPostRateExceeded = errors.New("rate limit for the client has been exceeded")
)

// Chat implements a chat service to publish, list and subscribe to messages in
// a room.
type Chat struct {
	logger.Logger
	rdb               *redis.Client
	subscribers       map[string]*subscriber
	subscribersMutex  sync.Mutex
	postLimiters      map[string]*rate.Limiter
	postLimitersMutex sync.Mutex
	quit              chan struct{}
	wg                sync.WaitGroup
}

// New creates a new Chat service.
func New(rdb *redis.Client) *Chat {
	return &Chat{
		Logger:       logger.Logger{Level: logger.Info, Prefix: "chat service"},
		rdb:          rdb,
		subscribers:  make(map[string]*subscriber),
		postLimiters: make(map[string]*rate.Limiter),
		quit:         make(chan struct{}, 1),
	}
}

// Run subscribes to RedisMsgChName and forwards the messages to the relevant
// subscribers.
func (chat *Chat) Run() {
	ctx := context.Background()

	chat.Infof("subscribing to PubSub channel")
	sub := chat.rdb.Subscribe(ctx, RedisMsgChName)
	ch := sub.Channel()

	for {
		select {
		case data := <-ch:
			chat.Debugf("received message from PubSub channel: ", data.Payload)
			var msg Message
			if err := json.Unmarshal([]byte(data.Payload), &msg); err != nil {
				chat.Errorf("failed to unmarshal message: %v", err)
				// TODO: notify sentry
			} else {
				chat.broadcast(msg)
			}

		case <-chat.quit:
			chat.Infof("unsubscribing from PubSub channel")
			sub.Unsubscribe(ctx, RedisMsgChName)

			chat.subscribersMutex.Lock()
			defer chat.subscribersMutex.Unlock()

			chat.Infof("notifying clients of server shutdown and closing connections")
			for _, sub := range chat.subscribers {
				close(sub.quit)
			}

			return
		}
	}
}

// broadcast sends the msg to the subscribers of the room it belongs to.
func (chat *Chat) broadcast(msg Message) {
	chat.subscribersMutex.Lock()
	defer chat.subscribersMutex.Unlock()
	for _, sub := range chat.subscribers {
		if msg.Room == sub.roomID {
			select {
			case sub.msgs <- msg:
			default:
				// don't block because of a slow connection, close it
				close(sub.quit)
			}
		}
	}
}

// listenToClientMessages waits for new messages from the client and forwards
// them appropriately.
func (chat *Chat) listenToClientMessages(sub *subscriber) {
	chat.wg.Add(1)
	defer chat.wg.Done()

	limiter := rate.NewLimiter(SubscriberRateLimit, SubscriberLimiterBurst)

	var msg Message
	for {
		limiter.Wait(context.Background())

		// Wait for the next message from the client.
		//
		// Note that wsutil automatically handles control frames (ping/pong).
		if raw, err := wsutil.ReadClientText(sub.conn); err != nil {
			chat.Infof("error received in listener: %v", err)

			if strings.Contains(err.Error(), "use of closed network connection") {
				chat.Infof("the connection was closed: closing client listener")
				return
			}

			sub.errCh <- err
			if errors.Is(err, io.EOF) {
				chat.Infof("received EOF: closing client listener")
				return
			}

		} else if err = json.Unmarshal(raw, &msg); err != nil {
			sub.errCh <- fmt.Errorf("error unmarshalling client message: %v", err)
		} else {
			chat.Debugf("received message from client: %+v", msg)
			sub.clientMsgs <- msg
		}
	}
}

// handleWSConnection gathers messages from all channels of the subscriber and
// sends them to the client.
func (chat *Chat) handleWSConnection(sub *subscriber) {
	chat.wg.Add(1)
	defer chat.wg.Done()

	defer sub.conn.Close()
	defer chat.unsubscribe(sub)

	for {
		select {
		case msg := <-sub.msgs:
			if data, err := json.Marshal(msg); err != nil {
				sub.errCh <- err
			} else if err := wsutil.WriteServerMessage(sub.conn, ws.OpText, data); err != nil {
				sub.errCh <- err
			} else {
				chat.Debugf("sent message to subscriber: %+v", msg)
			}

		case clientMsg := <-sub.clientMsgs:
			// No data messages from the client are currently supported.
			sub.errCh <- fmt.Errorf("unsupported message type '%v'", clientMsg.Type)

		case err := <-sub.errCh:
			chat.Debugf("error received in handler: %+v", err)

			if errors.Is(err, io.EOF) || strings.Contains(err.Error(), "use of closed network connection") {
				chat.Infof("the connection was closed: closing client listener")
				close(sub.quit)
				return
			}

			sub.msgs <- Message{
				ID:        uuid.New().String(),
				Type:      "error",
				Timestamp: time.Now().UnixMilli(),
				Error:     err.Error(),
			}

		case <-sub.quit:
			if closeMsg, err := json.Marshal(Message{Type: "shutdown"}); err != nil {
				chat.Errorf("failed to marshal shutdown message: %v", err)
			} else {
				sub.conn.SetDeadline(time.Now().Add(10 * time.Second))
				if err := wsutil.WriteServerMessage(sub.conn, ws.OpClose, closeMsg); err != nil {
					chat.Infof("failed to send shutdown message: %v", err)
				}
			}
			return
		}
	}
}

// WSHandler upgrades the request to a websocket, to transmit messages received
// in the room back to the client.
//
// Returns an error if it fails to upgrade the connection.
func (chat *Chat) WSHandler(
	w http.ResponseWriter,
	r *http.Request,
	roomID, clientID string,
) error {
	// Upgrade connection to a websocket.
	conn, _, _, err := ws.UpgradeHTTP(r, w)
	if err != nil {
		return fmt.Errorf("failed to accept connection: %v", err)
	}

	// A random code is used to store this connection in the subscribers map,
	// so that the same user can connect multiple times without the connection
	// being overwritten (for example, from multiple devices).
	code := random.AlphanumericString(10)
	sub := chat.subscribe(conn, roomID, clientID, code)

	go chat.listenToClientMessages(sub)
	go chat.handleWSConnection(sub)
	return nil
}

// Messages returns the messages in a given room, ordered from the most recent
// to the oldest.
func (chat *Chat) Messages(
	ctx context.Context,
	roomID string,
	limit int64,
	offset int64,
) ([]Message, error) {
	raw, err := chat.rdb.ZRevRange(
		ctx,
		roomID,
		offset,
		offset+limit-1, // `stop` is inclusive, hence the -1
	).Result()
	if err != nil {
		return nil, err
	}

	msgs := make([]Message, 0, len(raw))
	for _, data := range raw {
		var msg Message
		if err := json.Unmarshal([]byte(data), &msg); err != nil {
			chat.Errorf("error unmarshalling message: %v", err)
			// TODO: notify sentry
		} else {
			msgs = append(msgs, msg)
		}
	}

	return msgs, nil
}

// Post publishes the message in the PubSub channel and stores it in a sorted
// set keyed by the roomId.
//
// There is a rate limit on messages from msg.From, which results in an
// ErrPostTrafficExceeded.
func (chat *Chat) Post(ctx context.Context, msg Message) error {
	chat.postLimitersMutex.Lock()
	limiter, ok := chat.postLimiters[msg.From]
	if !ok {
		limiter = rate.NewLimiter(PostRateLimit, PostLimiterBurst)
		chat.postLimiters[msg.From] = limiter
	}
	chat.postLimitersMutex.Unlock()

	if !limiter.Allow() {
		return ErrPostRateExceeded
	} // limiter.Allow consumes a token, so there's no need to wait.

	raw, err := json.Marshal(msg)
	if err != nil {
		return err
	}

	chat.Debugf("publishing to redis: %s", string(raw))
	if err = chat.rdb.Publish(ctx, RedisMsgChName, raw).Err(); err != nil {
		return err
	}

	return chat.rdb.ZAdd(ctx, msg.Room, &redis.Z{
		Score:  float64(msg.Timestamp),
		Member: raw,
	}).Err()
}

// Stop this chat service.
// Any currently open WebSocket connections will receive a "server shutdown"
// message prior to closing.
func (chat *Chat) Stop(ctx context.Context) error {
	chat.Infof("stopping")
	close(chat.quit)

	chat.Infof("waiting for current connections to close")
	ch := make(chan struct{})
	go func() {
		defer close(ch)
		chat.wg.Wait()
	}()

	select {
	case <-ch:
	case <-ctx.Done():
		return errors.New("timeout waiting for connections to close, stopping anyway")
	}

	chat.Infof("stopped")
	return nil
}
