package interfaces

import (
	"context"
	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
)

type IInterviewStructuredRepository interface {
	StartInterview(ctx context.Context, userID, field string, userProfile map[string]interface{}, questions []string) (string, error)
	AppendMessage(ctx context.Context, chatID string, message models.InterviewStructuredMessage) error
	GetInterviewChatByID(ctx context.Context, chatID string) (*models.InterviewStructuredChat, error)
	GetInterviewChatByIDWithLimit(ctx context.Context, chatID string, limit, offset int) (*models.InterviewStructuredChat, error)
	GetInterviewChatsByUserIDWithLimit(ctx context.Context, userID string, limit, offset int) ([]*models.InterviewStructuredChat, error)
	GetInterviewChatsByUserID(ctx context.Context, userID string) ([]*models.InterviewStructuredChat, error)
	GetChatHistory(ctx context.Context, chatID string) (*models.InterviewStructuredChat, error)
	GetChatHistoryWithLimit(ctx context.Context, chatID string, limit, offset int) (*models.InterviewStructuredChat, error)
	GetUserInterviewChats(ctx context.Context, userID string) ([]*models.InterviewStructuredChat, error)
	UpdateInterviewState(ctx context.Context, chatID string, currentQuestion int, inInterview bool) error
	UpdateSessionState(ctx context.Context, chatID string, currentQuestion int, isCompleted bool) error
	DeleteInterviewChat(ctx context.Context, chatID string) error
}
