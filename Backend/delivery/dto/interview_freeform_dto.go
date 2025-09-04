package dto

import (
	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
	"time"
)

// Freeform Interview DTOs
type CreateInterviewSessionRequest struct {
	SessionType string `json:"session_type" binding:"required"` // "general", "technical", "behavioral"
}

type CreateInterviewSessionResponse struct {
	ChatID      string    `json:"chat_id"`
	UserID      string    `json:"user_id"`
	SessionType string    `json:"session_type"`
	Message     string    `json:"message"`
	CreatedAt   time.Time `json:"created_at"`
}

type SendInterviewMessageRequest struct {
	Message string `json:"message" binding:"required"`
	ChatID  string `json:"chat_id" binding:"required"`
}

type SendInterviewMessageResponse struct {
	ID        string    `json:"id"`
	Role      string    `json:"role"`
	Content   string    `json:"content"`
	Timestamp time.Time `json:"timestamp"`
}

type InterviewChatHistoryResponse struct {
	ChatID      string                         `json:"chat_id"`
	UserID      string                         `json:"user_id"`
	SessionType string                         `json:"session_type"`
	Messages    []SendInterviewMessageResponse `json:"messages"`
	CreatedAt   time.Time                      `json:"created_at"`
	UpdatedAt   time.Time                      `json:"updated_at"`
}

type UserInterviewChatsResponse struct {
	Chats []InterviewChatSummary `json:"chats"`
	Total int                    `json:"total"`
}

type InterviewChatSummary struct {
	ChatID      string    `json:"chat_id"`
	SessionType string    `json:"session_type"`
	LastMessage string    `json:"last_message"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// Conversion functions
func ToSendInterviewMessageResponse(message *models.InterviewFreeformMessage) *SendInterviewMessageResponse {
	return &SendInterviewMessageResponse{
		ID:        message.ID,
		Role:      message.Role,
		Content:   message.Content,
		Timestamp: message.Timestamp,
	}
}

func ToInterviewChatHistoryResponse(chat *models.InterviewFreeformChat) *InterviewChatHistoryResponse {
	var messages []SendInterviewMessageResponse
	for _, msg := range chat.Messages {
		messages = append(messages, *ToSendInterviewMessageResponse(&msg))
	}

	return &InterviewChatHistoryResponse{
		ChatID:      chat.ID,
		UserID:      chat.UserID,
		SessionType: chat.SessionType,
		Messages:    messages,
		CreatedAt:   chat.CreatedAt,
		UpdatedAt:   chat.UpdatedAt,
	}
}

func ToInterviewChatSummary(chat *models.InterviewFreeformChat) InterviewChatSummary {
	lastMessage := ""
	if len(chat.Messages) > 0 {
		lastMessage = chat.Messages[len(chat.Messages)-1].Content
		if len(lastMessage) > 100 {
			lastMessage = lastMessage[:100] + "..."
		}
	}

	return InterviewChatSummary{
		ChatID:      chat.ID,
		SessionType: chat.SessionType,
		LastMessage: lastMessage,
		CreatedAt:   chat.CreatedAt,
		UpdatedAt:   chat.UpdatedAt,
	}
}
