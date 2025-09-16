package models

import (
	"time"
)


type InterviewFreeformMessage struct {
	ID        string
	Role      string // "user" or "assistant"
	Content   string
	Timestamp time.Time
}


type InterviewFreeformChat struct {
	ID          string
	UserID      string
	SessionType string // "general", "technical", "behavioral"
	Messages    []InterviewFreeformMessage
	CreatedAt   time.Time
	UpdatedAt   time.Time
}
