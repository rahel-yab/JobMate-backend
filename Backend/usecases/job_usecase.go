package usecases

import (
	"context"
	"fmt"

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

func (uc *JobUsecase) SuggestJobs(ctx context.Context, userID string, req models.JobSuggestionRequest, chatMsgs []models.JobChatMessage) (jobs []models.Job, aiMessage string, msg string, chatID string, err error) {
	var messageContent string
	
	if len(chatMsgs) > 0 {
		messageContent = chatMsgs[len(chatMsgs)-1].Message
	} else {
		messageContent = fmt.Sprintf("I want to find %s %s jobs", req.LookingFor, req.Field)
		
		if len(req.Skills) > 0 {
			messageContent += fmt.Sprintf(". I have skills in %s", joinStrings(req.Skills))
		}
		
		if req.Experience != "" {
			messageContent += fmt.Sprintf(" and I'm looking for %s level positions", req.Experience)
		}
		
		messageContent += ". Please search for available jobs using your job search function."
	}

	response, err := uc.JobAIService.HandleJobConversation(ctx, userID, messageContent, "")
	if err != nil {
		return nil, "", "Failed to process job search", "", err
	}

	return response.Jobs, response.Message, "Job search completed", response.ChatID, nil
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