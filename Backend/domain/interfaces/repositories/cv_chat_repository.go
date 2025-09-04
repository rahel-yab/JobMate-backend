package interfaces

import (
	"context"

	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
)

type ICVChatRepository interface {
	CreateCVChat(ctx context.Context, userID string, cvID string) (string, error)
	AppendMessage(ctx context.Context, chatID string, message models.CVChatMessage) error
	GetCVChatByID(ctx context.Context, chatID string) (*models.CVChat, error)
	GetCVChatByIDWithLimit(ctx context.Context, chatID string, limit int, offset int) (*models.CVChat, error)
	GetCVChatsByUserID(ctx context.Context, userID string) ([]*models.CVChat, error)
	GetCVChatsByUserIDWithLimit(ctx context.Context, userID string, limit int, offset int) ([]*models.CVChat, error)
	DeleteCVChat(ctx context.Context, chatID string) error
}
