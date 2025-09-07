package controllers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/tsigemariamzewdu/JobMate-backend/delivery/dto"
	"github.com/tsigemariamzewdu/JobMate-backend/infrastructure/ai"
	"github.com/tsigemariamzewdu/JobMate-backend/repositories"
	"github.com/tsigemariamzewdu/JobMate-backend/usecases"
	"github.com/tsigemariamzewdu/JobMate-backend/infrastructure/ai_service"
)

type JobController struct {
	JobUsecase  *usecases.JobUsecase
	JobChatRepo *repositories.JobChatRepository
	GroqClient  *ai.GroqClient
	JobAIService *ai_service.JobAIService
}

func NewJobController(jobUsecase *usecases.JobUsecase, jobChatRepo *repositories.JobChatRepository, groqClient *ai.GroqClient, jobAIService *ai_service.JobAIService) *JobController {
	return &JobController{
		JobUsecase:  jobUsecase,
		JobChatRepo: jobChatRepo,
		GroqClient:  groqClient,
		JobAIService: jobAIService,
	}
}

func (jc *JobController) Chat(c *gin.Context) {
	var req dto.JobChatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}
 
	// Get user ID from authentication middleware
	userID := c.GetString("userID")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Authentication required"})
		return
	}

	response, err := jc.JobUsecase.Chat(c.Request.Context(), userID, req.Message, req.ChatID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process request"})
		return
	}

	// Convert domain jobs to DTOs
	var jobDTOs []dto.JobDTO
	for _, job := range response.Jobs {
		jobDTOs = append(jobDTOs, dto.JobDTO{
			Title:        job.Title,
			Company:      job.Company,
			Location:     job.Location,
			Requirements: job.Requirements,
			Type:         job.Type,
			Source:       job.Source,
			Link:         job.Link,
			Language:     job.Language,
		})
	}

	c.JSON(http.StatusOK, dto.JobChatResponse{
		Message: response.Message,
		Jobs:    jobDTOs,
		ChatID:  response.ChatID,
		Action:  response.Action,
	})
}

func (jc *JobController) GetUserChats(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Authentication required"})
		return
	}

	chats, err := jc.JobUsecase.GetUserJobChats(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch chats"})
		return
	}

	c.JSON(http.StatusOK, chats)
}

func (jc *JobController) GetChat(c *gin.Context) {
	chatID := c.Param("id")
	if chatID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Chat ID required"})
		return
	}

	chat, err := jc.JobUsecase.GetJobChat(c.Request.Context(), chatID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch chat"})
		return
	}

	c.JSON(http.StatusOK, chat)
}