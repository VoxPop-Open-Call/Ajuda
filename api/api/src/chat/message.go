package chat

type Message struct {
	ID        string `json:"id"`
	Type      string `json:"type"`
	Timestamp int64  `json:"timestamp"`
	ReplyTo   string `json:"replyTo,omitempty"`
	Room      string `json:"room,omitempty"`
	From      string `json:"from,omitempty"`
	Text      string `json:"text,omitempty"`
	Error     string `json:"error,omitempty"`
}
