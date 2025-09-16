package interfaces

import (
	"context"
	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
)

type IInterviewFreeformRepository interface {
	CreateInterviewChat(ctx context.Context, userID string, sessionType string) (string, error)
	AppendMessage(ctx context.Context, chatID string, message models.InterviewFreeformMessage) (*models.InterviewFreeformMessage, error)
	GetInterviewChatByID(ctx context.Context, chatID string) (*models.InterviewFreeformChat, error)
	GetInterviewChatByIDWithLimit(ctx context.Context, chatID string, limit, offset int) (*models.InterviewFreeformChat, error)
	GetInterviewChatsByUserIDWithLimit(ctx context.Context, userID string, limit, offset int) ([]*models.InterviewFreeformChat, error)
	GetInterviewChatsByUserID(ctx context.Context, userID string) ([]*models.InterviewFreeformChat, error)
	DeleteInterviewChat(ctx context.Context, chatID string) error
}
