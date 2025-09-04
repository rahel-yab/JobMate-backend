package dto

import (
	"time"

	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
)

type CVChatRequest struct {
	Message string `json:"message" binding:"required"`
	CVID    string `json:"cv_id,omitempty"`
}

type CVChatResponse struct {
	ID        string    `json:"id"`
	Role      string    `json:"role"`
	Content   string    `json:"content"`
	Timestamp time.Time `json:"timestamp"`
}

type CVChatSessionRequest struct {
	CVID string `json:"cv_id,omitempty"`
}

type CVChatSessionResponse struct {
	ChatID    string                `json:"chat_id"`
	UserID    string                `json:"user_id"`
	CVID      string                `json:"cv_id,omitempty"`
	Messages  []CVChatResponse      `json:"messages"`
	CreatedAt time.Time             `json:"created_at"`
	UpdatedAt time.Time             `json:"updated_at"`
}

func ToCVChatResponse(message *models.CVChatMessage) *CVChatResponse {
	return &CVChatResponse{
		ID:        message.ID,
		Role:      message.Role,
		Content:   message.Content,
		Timestamp: message.Timestamp,
	}
}

func ToCVChatSessionResponse(chat *models.CVChat) *CVChatSessionResponse {
	var messages []CVChatResponse
	for _, msg := range chat.Messages {
		messages = append(messages, *ToCVChatResponse(&msg))
	}
	
	return &CVChatSessionResponse{
		ChatID:    chat.ID,
		UserID:    chat.UserID,
		CVID:      chat.CVID,
		Messages:  messages,
		CreatedAt: chat.CreatedAt,
		UpdatedAt: chat.UpdatedAt,
	}
}
