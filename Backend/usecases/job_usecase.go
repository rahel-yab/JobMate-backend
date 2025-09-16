package usecases

import (
	"context"

	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
	"github.com/tsigemariamzewdu/JobMate-backend/infrastructure/ai_service"
	"github.com/tsigemariamzewdu/JobMate-backend/infrastructure/job_service"
	"github.com/tsigemariamzewdu/JobMate-backend/repositories"
)

type JobUsecase struct {
	JobService   *job_service.JobService
	JobChatRepo  *repositories.JobChatRepository
	JobAIService *ai_service.JobAIService
}

func NewJobUsecase(jobService *job_service.JobService, jobChatRepo *repositories.JobChatRepository, jobAIService *ai_service.JobAIService) *JobUsecase {
	return &JobUsecase{
		JobService:   jobService,
		JobChatRepo:  jobChatRepo,
		JobAIService: jobAIService,
	}
}

func (uc *JobUsecase) Chat(ctx context.Context, userID string, message string, chatID string) (*models.JobAIResponse, error) {
	return uc.JobAIService.HandleJobConversation(ctx, userID, message, chatID)
}

func (uc *JobUsecase) GetUserJobChats(ctx context.Context, userID string) ([]*models.JobChat, error) {
	return uc.JobChatRepo.GetJobChatsByUserID(ctx, userID)
}

func (uc *JobUsecase) GetJobChat(ctx context.Context, chatID string) (*models.JobChat, error) {
	return uc.JobChatRepo.GetJobChatByID(ctx, chatID)
}

func joinStrings(strs []string) string {
	if len(strs) == 0 {
		return ""
	}
	if len(strs) == 1 {
		return strs[0]
	}
	
	result := strs[0]
	for i := 1; i < len(strs)-1; i++ {
		result += ", " + strs[i]
	}
	result += " and " + strs[len(strs)-1]
	return result
}