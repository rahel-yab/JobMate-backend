package models

import (
	"time"
)


type InterviewStructuredMessage struct {
	ID            string
	Role          string // "user" or "assistant"
	Content       string
	QuestionIndex int 
	Timestamp     time.Time
}


type InterviewStructuredChat struct {
	ID              string
	UserID          string
	Field           string // interview field (e.g., software_engineering)
	UserProfile     map[string]interface{} // user experience, skills, etc.
	Questions       []string 
	Messages        []InterviewStructuredMessage
	CurrentQuestion int
	IsCompleted     bool
	CreatedAt       time.Time
	UpdatedAt       time.Time
}
