package chat

import (
	"context"
	"net"
)

type subscriber struct {
	conn     net.Conn
	clientID string
	roomID   string
	code     string

	// Channel to publish messages to the client.
	msgs chan Message

	// Channel to receive messages from the client.
	clientMsgs chan Message

	// Channel to transmit any errors that occur in this connection.
	// EOF and timeout errors will close the connection.
	errCh chan error

	// Channel to close the connection. Used when the server is shutting down
	// or the connection to the client is too slow.
	quit chan struct{}
}

func (s subscriber) key() string {
	return s.roomID + s.clientID + s.code
}

func redisSubscriberKey(roomID, clientID string) string {
	return "subscriber:" + clientID + ":" + roomID
}

func (s subscriber) redisKey() string {
	return redisSubscriberKey(s.roomID, s.clientID)
}

func (chat *Chat) subscribe(
	conn net.Conn,
	roomID, clientID, code string,
) *subscriber {
	chat.subscribersMutex.Lock()
	defer chat.subscribersMutex.Unlock()

	chat.Infof("new subscriber: %v to %v", clientID, roomID)
	sub := &subscriber{
		conn:       conn,
		clientID:   clientID,
		roomID:     roomID,
		code:       code,
		msgs:       make(chan Message, PublishChBufferSize),
		clientMsgs: make(chan Message, ClientChBufferSize),
		errCh:      make(chan error, ErrChBufferSize),
		quit:       make(chan struct{}, 1),
	}
	chat.subscribers[sub.key()] = sub
	chat.rdb.Incr(context.TODO(), sub.redisKey())
	return sub
}

func (chat *Chat) unsubscribe(sub *subscriber) {
	chat.subscribersMutex.Lock()
	defer chat.subscribersMutex.Unlock()

	chat.Infof("unsubscribing: %v from %v", sub.clientID, sub.roomID)
	delete(chat.subscribers, sub.key())
	chat.rdb.Decr(context.TODO(), sub.redisKey())

	close(sub.msgs)
	close(sub.clientMsgs)
	close(sub.errCh)
}

// HasSubscriber returns whether the given client is currently subscribed to
// the room, on any instance of this chat service.
func (chat *Chat) HasSubscriber(
	ctx context.Context,
	roomID, clientID string,
) bool {
	res := chat.rdb.Get(ctx, redisSubscriberKey(roomID, clientID))
	if res.Err() != nil {
		return false
	}

	v, err := res.Int64()
	return err == nil && v > 0
}
