package chat

import (
	"context"
	"encoding/json"

	"bitbucket.org/mobinteg/ajuda-mais/src/util/random"
)

func tokenKey(token string) string {
	return "token:" + token
}

type token struct {
	RoomID   string
	ClientID string
}

func encode(roomID, clientID string) ([]byte, error) {
	return json.Marshal(token{roomID, clientID})
}

func decode(raw []byte) (roomID, clientID string, err error) {
	var t token
	err = json.Unmarshal(raw, &t)
	return t.RoomID, t.ClientID, err
}

// NewToken generates a temporary token used to authenticate the WebSocket
// handshake.
func (chat *Chat) NewToken(
	ctx context.Context,
	roomID, clientID string,
) (string, error) {
	token := random.AlphanumericString(TempAuthTokenLength)
	raw, err := encode(roomID, clientID)
	if err != nil {
		return "", err
	}

	res := chat.rdb.SetEX(ctx, tokenKey(token), raw, TempAuthTokenTTL)
	return token, res.Err()
}

// RedeemToken retrieves the room and client IDs associated with a temporary
// token, for validation. A token can only be retrieved once.
func (chat *Chat) RedeemToken(
	ctx context.Context,
	token string,
) (roomID, clientID string, err error) {
	res := chat.rdb.GetDel(ctx, tokenKey(token))
	err = res.Err()
	val := res.Val()
	if err != nil || val == "" {
		return "", "", err
	}
	return decode([]byte(val))
}
