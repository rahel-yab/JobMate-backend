package interfaces

import (
	"context"

	"github.com/tsigemariamzewdu/JobMate-backend/delivery/dto"
	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
)

type IInterviewStructuredUsecase interface {
	StartStructuredInterview(ctx context.Context, userID, field, preferredLanguage string) (chatID, firstQuestion string, totalQuestions int, err error)
	ProcessAnswer(ctx context.Context, userID, chatID, answer string) (*dto.InterviewAnswerResponse, error)
	GetNextQuestion(ctx context.Context, chatID string) (string, error)
	GetChatHistory(ctx context.Context, chatID string) (*models.InterviewStructuredChat, error)
	GetChatHistoryWithLimit(ctx context.Context, chatID string, limit, offset int) (*models.InterviewStructuredChat, error)
	GetUserInterviewChats(ctx context.Context, userID string) ([]*models.InterviewStructuredChat, error)
	ResumeInterview(ctx context.Context, userID, chatID string) (*models.InterviewStructuredChat, error)
	CompleteSession(ctx context.Context, chatID string) error
}
