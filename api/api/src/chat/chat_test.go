package chat

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"io/ioutil"
	"net"
	"net/http"
	"net/http/httptest"
	"os"
	"regexp"
	"strings"
	"testing"
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/config"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/logger"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/random"
	"github.com/go-redis/redis/v8"
	"github.com/gobwas/ws"
	"github.com/gobwas/ws/wsutil"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

var rdb *redis.Client

func TestToken(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	chat := New(rdb)

	roomID := random.AlphanumericString(10)
	clientID := random.AlphanumericString(10)

	token, err := chat.NewToken(ctx, roomID, clientID)
	require.NoError(t, err)

	room, client, err := chat.RedeemToken(ctx, token)
	assert.NoError(t, err)
	assert.Equal(t, roomID, room)
	assert.Equal(t, clientID, client)

	// token can only be retrieved once:
	_, _, err = chat.RedeemToken(ctx, token)
	assert.EqualError(t, err, redis.Nil.Error())

	TempAuthTokenTTL = time.Second // Redis doesn't accept a ttl lower than 1sec.
	token, err = chat.NewToken(ctx, roomID, clientID)
	require.NoError(t, err)
	time.Sleep(1100 * time.Millisecond)
	_, _, err = chat.RedeemToken(ctx, token)
	assert.EqualError(t, err, redis.Nil.Error())
}

func TestHasSubscriber(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	chat := New(rdb)
	chat.Logger.Level = logger.Silent

	roomID := random.String(30)
	clientID := uuid.New().String()
	defer chat.rdb.Del(ctx, redisSubscriberKey(roomID, clientID))

	assert.False(t, chat.HasSubscriber(ctx, roomID, clientID))

	code := random.AlphanumericString(30)
	sub1 := chat.subscribe(nil, roomID, clientID, code)
	assert.True(t, chat.HasSubscriber(ctx, roomID, clientID))

	code = random.AlphanumericString(30)
	sub2 := chat.subscribe(nil, roomID, clientID, code)
	assert.True(t, chat.HasSubscriber(ctx, roomID, clientID))

	chat.unsubscribe(sub1)
	assert.True(t, chat.HasSubscriber(ctx, roomID, clientID))

	chat.unsubscribe(sub2)
	assert.False(t, chat.HasSubscriber(ctx, roomID, clientID))
}

func TestPost(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	chat := New(rdb)
	chat.Logger.Level = logger.Silent

	ch := make(chan string, 1)
	ready := make(chan struct{}, 1)

	go func() {
		sub := chat.rdb.Subscribe(ctx, RedisMsgChName)
		subCh := sub.Channel()
		close(ready)

		for {
			select {
			case data := <-subCh:
				ch <- data.Payload
				return
			case <-ctx.Done():
				t.Log("context canceled")
			}
		}
	}()

	timestamp := time.Now().UnixMilli()
	roomID := "test-room:" + random.AlphanumericString(20)
	msg := Message{
		ID:        uuid.New().String(),
		Type:      "text",
		Timestamp: timestamp,
		Room:      roomID,
		Text:      random.String(300),
	}
	defer chat.rdb.Del(ctx, roomID)

	<-ready

	time.Sleep(50 * time.Millisecond)
	err := chat.Post(ctx, msg)
	require.NoError(t, err)

	var res Message
	select {
	case raw := <-ch:
		err = json.Unmarshal([]byte(raw), &res)
		require.NoError(t, err)
	case <-time.After(2000 * time.Millisecond):
		assert.Fail(t, "timeout waiting for message")
	}

	assert.Equal(t, msg, res)
}

func TestMessages(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	chat := New(rdb)
	chat.Logger.Level = logger.Silent

	roomID := "test-room:" + random.AlphanumericString(20)
	defer chat.rdb.Del(ctx, roomID)

	msgs := make([]Message, 100, 100)
	PostLimiterBurst = 100 // Disable rate limiting for this test.
	for i := 0; i < 100; i++ {
		msg := Message{
			ID:        uuid.New().String(),
			Type:      "text",
			Timestamp: time.Now().Add(time.Duration(10*i) * time.Second).UnixMilli(),
			Room:      roomID,
			Text:      random.String(300),
		}
		msgs[99-i] = msg
		err := chat.Post(ctx, msg)
		require.NoError(t, err)
	}

	res, err := chat.Messages(ctx, roomID, 10, 0)
	require.NoError(t, err)
	assert.Equal(t, msgs[:10], res)

	res, err = chat.Messages(ctx, roomID, 50, 12)
	require.NoError(t, err)
	assert.Equal(t, msgs[12:62], res)
}

func TestBroadcast(t *testing.T) {
	chat := New(rdb)
	chat.Logger.Level = logger.Silent

	sub0 := chat.subscribe(nil, "room0", "client0", "012")
	sub1 := chat.subscribe(nil, "room0", "client1", "345")
	sub2 := chat.subscribe(nil, "room1", "client2", "678")
	sub3 := chat.subscribe(nil, "room1", "client2", "9ab")
	defer func() {
		chat.unsubscribe(sub0)
		chat.unsubscribe(sub1)
		chat.unsubscribe(sub2)
		chat.unsubscribe(sub3)
		chat.rdb.Del(context.Background(), sub0.redisKey())
		chat.rdb.Del(context.Background(), sub1.redisKey())
		chat.rdb.Del(context.Background(), sub2.redisKey())
		chat.rdb.Del(context.Background(), sub3.redisKey())
	}()

	msg0 := Message{
		Room: "room0",
		Text: "test message on room0",
	}
	msg1 := Message{
		Room: "room1",
		Text: "test message on room1",
	}

	chat.broadcast(msg0)
	chat.broadcast(msg1)

	count := 0
	for count < 4 {
		select {
		case sub0msg := <-sub0.msgs:
			assert.Equal(t, msg0, sub0msg)
		case sub1msg := <-sub1.msgs:
			assert.Equal(t, msg0, sub1msg)
		case sub2msg := <-sub2.msgs:
			assert.Equal(t, msg1, sub2msg)
		case sub3msg := <-sub3.msgs:
			assert.Equal(t, msg1, sub3msg)
		case <-time.After(time.Second):
			require.FailNow(t, "timeout waiting for messages")
			return
		}

		count++
	}
}

func TestHandleWSConnection(t *testing.T) {
	chat := New(rdb)
	chat.Logger.Level = logger.Silent

	mockConn := &BufferCloser{}
	sub := &subscriber{
		roomID:     "abcde",
		clientID:   "123456",
		conn:       mockConn,
		msgs:       make(chan Message, PublishChBufferSize),
		clientMsgs: make(chan Message, ClientChBufferSize),
		errCh:      make(chan error, ErrChBufferSize),
		quit:       make(chan struct{}, 1),
	}
	defer chat.rdb.Del(context.Background(), "subscriber:123456:abcde")

	go chat.handleWSConnection(sub)

	var assertMessage = func(exp *regexp.Regexp) {
		var bs []byte
		var err error
		for i := 0; i < 10; i++ {
			bs, err = ioutil.ReadAll(sub.conn)
			if err != nil {
				close(sub.quit)
				t.FailNow()
			}
			if len(bs) == 0 {
				time.Sleep(5 * time.Millisecond)
				continue
			}
			break
		}

		assert.Regexp(t, exp, string(bs))
	}

	// ---------------------------- //
	// Sends messages to the client //
	// ---------------------------- //
	sub.msgs <- Message{Text: "Text Message"}
	assertMessage(regexp.MustCompile("\"text\":\"Text Message\""))

	// ------------------------- //
	// Sends error to the client //
	// ------------------------- //
	sub.errCh <- errors.New("ups")
	assertMessage(regexp.MustCompile("\"error\":\"ups\""))

	// -------------------------------------------------- //
	// Sends error on unsupported message from the client //
	// -------------------------------------------------- //
	sub.clientMsgs <- Message{Type: "sup"}
	assertMessage(regexp.MustCompile("\"error\":\"unsupported message type 'sup'\""))

	// ------------------------------- //
	// Sends a Server Shutdown message //
	// ------------------------------- //
	close(sub.quit)
	assertMessage(regexp.MustCompile("\"type\":\"shutdown\""))

	// ------------------------------ //
	// Assert handler closes properly //
	// ------------------------------ //
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	ch := make(chan struct{})
	go func() {
		defer close(ch)
		chat.wg.Wait()
	}()

	select {
	case <-ch:
	case <-ctx.Done():
		t.FailNow()
	}
}

func TestServer(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	chat := New(rdb)
	go chat.Run()
	defer chat.Stop(ctx)
	defer chat.rdb.Del(context.Background(), "subscriber:client0:room0")
	defer chat.rdb.Del(context.Background(), "room0")
	chat.Logger.Level = logger.Silent

	s := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		chat.WSHandler(w, r, "room0", "client0")
	}))
	defer s.Close()

	wsURL := "ws" + strings.TrimPrefix(s.URL, "http")
	conn, _, _, err := ws.Dial(ctx, wsURL)
	require.NoError(t, err)

	// ----------------------------------- //
	// Try sending a message to the server //
	// ----------------------------------- //
	data, err := json.Marshal(Message{Type: "yo"})
	require.NoError(t, err)

	ready := make(chan struct{}, 1)
	next := make(chan struct{}, 1)
	go func() {
		// Expect the server to return an "unsupported message type" error.
		conn.SetReadDeadline(time.Now().Add(time.Second * 30))
		close(ready)
		raw, err := wsutil.ReadServerText(conn)
		require.NoError(t, err)
		assert.Regexp(t, regexp.MustCompile(
			"\"error\":\"unsupported message type 'yo'\"",
		), string(raw))
		close(next)
	}()

	<-ready
	time.Sleep(100 * time.Millisecond)
	wsutil.WriteClientMessage(conn, ws.OpText, data)
	<-next

	// -------------------------------------- //
	// A posted message is sent to the client //
	// -------------------------------------- //
	msg := Message{
		ID:   "123456789",
		Type: "text",
		Room: "room0",
		From: "client1",
		Text: "test text msg",
	}

	ready = make(chan struct{}, 1)
	next = make(chan struct{}, 1)
	go func() {
		conn.SetReadDeadline(time.Now().Add(time.Second * 30))
		close(ready)
		raw, err := wsutil.ReadServerText(conn)
		require.NoError(t, err)

		var res Message
		err = json.Unmarshal(raw, &res)
		require.NoError(t, err)
		assert.Equal(t, msg, res)
		close(next)
	}()

	<-ready
	time.Sleep(100 * time.Millisecond)
	chat.Post(ctx, msg)
	<-next

	// ------------------------------- //
	// Assert listener closes properly //
	// ------------------------------- //
	conn.Close()

	timeoutCtx, cancelTimeout := context.WithTimeout(ctx, 10*time.Second)
	defer cancelTimeout()

	ch := make(chan struct{})
	go func() {
		defer close(ch)
		chat.wg.Wait()
	}()

	select {
	case <-ch:
	case <-timeoutCtx.Done():
		t.FailNow()
	}
}

func TestMain(m *testing.M) {
	conf, _ := config.Load("../../.env")
	rdb = redis.NewClient(&redis.Options{Addr: conf.RedisAddr()})
	os.Exit(m.Run())
}

// BufferCloser mocks a net.Conn.
type BufferCloser struct {
	bytes.Buffer
}

func (b *BufferCloser) Close() error {
	return nil
}

func (b *BufferCloser) LocalAddr() net.Addr {
	return nil
}

func (b *BufferCloser) RemoteAddr() net.Addr {
	return nil
}

func (b *BufferCloser) SetDeadline(_ time.Time) error {
	return nil
}

func (b *BufferCloser) SetReadDeadline(_ time.Time) error {
	return nil
}

func (b *BufferCloser) SetWriteDeadline(_ time.Time) error {
	return nil
}
