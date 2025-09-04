package models

import (
	"time"
)

// CVChatMessage represents a single message in CV chat
type CVChatMessage struct {
	ID        string
	Role      string // "user" or "assistant"
	Content   string
	Timestamp time.Time
}

// CVChat represents a CV-focused chat session
type CVChat struct {
	ID        string
	UserID    string
	CVID      string // Associated CV if any
	Messages  []CVChatMessage
	CreatedAt time.Time
	UpdatedAt time.Time
}
