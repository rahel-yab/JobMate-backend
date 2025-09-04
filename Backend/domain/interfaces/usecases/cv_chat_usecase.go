package interfaces

import (
	"context"

	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
)

type ICVChatUsecase interface {
	SendMessage(ctx context.Context, userID string, message string, cvID string) (*models.CVChatMessage, error)
	CreateCVChatSession(ctx context.Context, userID string, cvID string) (string, error)
	GetChatHistory(ctx context.Context, chatID string) (*models.CVChat, error)
	GetChatHistoryWithLimit(ctx context.Context, chatID string, limit, offset int) (*models.CVChat, error)
	GetUserCVChats(ctx context.Context, userID string) ([]*models.CVChat, error)
}
