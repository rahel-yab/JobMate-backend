package interfaces

import (
	"context"
	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
)

type IInterviewFreeformUsecase interface {
	SendMessage(ctx context.Context, userID string, message string, chatID string) (*models.InterviewFreeformMessage, error)
	CreateInterviewSession(ctx context.Context, userID string, sessionType string) (string, error)
	GetChatHistory(ctx context.Context, chatID string) (*models.InterviewFreeformChat, error)
	GetChatHistoryWithLimit(ctx context.Context, chatID string, limit, offset int) (*models.InterviewFreeformChat, error)
	GetUserInterviewChats(ctx context.Context, userID string) ([]*models.InterviewFreeformChat, error)
	CompleteSession(ctx context.Context, chatID string) error
}
