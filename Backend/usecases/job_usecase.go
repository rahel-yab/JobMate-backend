package usecases

import (
	"context"
	"time"

	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
	interfaces "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/services"
	"github.com/tsigemariamzewdu/JobMate-backend/infrastructure/job_service"
	"github.com/tsigemariamzewdu/JobMate-backend/repositories"
)

type JobUsecase struct {
	JobService   *job_service.JobService
	JobChatRepo  *repositories.JobChatRepository
	AIService    interfaces.IAIService
}

func NewJobUsecase(jobService *job_service.JobService, jobChatRepo *repositories.JobChatRepository, aiService interfaces.IAIService) *JobUsecase {
	return &JobUsecase{
		JobService:  jobService,
		JobChatRepo: jobChatRepo,
		AIService:   aiService,
	}
}

// SuggestJobs handles the full job chat flow: fetch jobs, store chat, call AI, return all
func (uc *JobUsecase) SuggestJobs(ctx context.Context, userID string, req models.JobSuggestionRequest, chatMsgs []models.JobChatMessage) (jobs []models.Job, aiMessage string, msg string, chatID string, err error) {
	// Fetch jobs
	jobs, msg, err = uc.JobService.GetCuratedJobs(req.Field, req.LookingFor, req.Experience, req.Skills, req.Language)
	if err != nil {
		return nil, "", "No jobs found for your criteria", "", err
	}

	// Save or update job chat
	query := map[string]any{
		"looking_for": req.LookingFor,
		"field":       req.Field,
		"skills":      req.Skills,
		"experience":  req.Experience,
		"language":    req.Language,
	}
	chatID, _ = uc.JobChatRepo.CreateJobChat(ctx, userID, query, jobs, chatMsgs)

	// Prepare AI messages
	var aiMessages []interfaces.AIMessage
	for _, m := range chatMsgs {
		aiMessages = append(aiMessages, interfaces.AIMessage{
			Role:    m.Role,
			Content: m.Message,
		})
	}

	// Add job results as a system message
	if len(jobs) > 0 {
		jobSummary := "Job search results:\n"
		for _, job := range jobs {
			jobSummary += "- " + job.Title + " at " + job.Company + " (" + job.Location + ")\n"
		}
		aiMessages = append(aiMessages, interfaces.AIMessage{
			Role:    "system",
			Content: jobSummary,
		})
	}

	// Call AI service via adapter
	aiResp, _ := uc.AIService.GetChatCompletion(ctx, aiMessages, nil)

	// Save AI response to chat
	if aiResp != nil {
		_ = uc.JobChatRepo.AppendMessage(ctx, chatID, models.JobChatMessage{
			Role:      "assistant",
			Message:   aiResp.Content,
			Timestamp: time.Now(),
		})
	}

	return jobs, aiResp.Content, msg, chatID, nil
}
