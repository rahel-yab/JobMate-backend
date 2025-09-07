package ai_service

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"regexp"
	"time"

	"github.com/tsigemariamzewdu/JobMate-backend/delivery/dto"
	"github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/repositories"
	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
	"github.com/tsigemariamzewdu/JobMate-backend/infrastructure/ai"
	"github.com/tsigemariamzewdu/JobMate-backend/infrastructure/job_service"
	"github.com/tsigemariamzewdu/JobMate-backend/repositories"
)

type JobAIService struct {
	GroqClient  *ai.GroqClient
	JobService  *job_service.JobService
	UserRepo    interfaces.IUserRepository
	JobChatRepo *repositories.JobChatRepository
}

func NewJobAIService(groqClient *ai.GroqClient, jobService *job_service.JobService, userRepo interfaces.IUserRepository, jobChatRepo *repositories.JobChatRepository) *JobAIService {
	return &JobAIService{
		GroqClient:  groqClient,
		JobService:  jobService,
		UserRepo:    userRepo,
		JobChatRepo: jobChatRepo,
	}
}

func (s *JobAIService) HandleJobConversation(ctx context.Context, userID string, userMessage string, chatID string) (*models.JobAIResponse, error) {
	// Get chat history
	var chatHistory []models.JobChatMessage
	if chatID != "" {
		chat, err := s.JobChatRepo.GetJobChatByID(ctx, chatID)
		if err == nil && chat != nil {
			chatHistory = chat.Messages
		}
	}

	// Get user profile for context
	var userProfile *models.User
	if userID != "" {
		userProfile, _ = s.UserRepo.GetByID(ctx, userID)
	}

	// Prepare AI messages with system prompt
	messages := s.prepareAIMessages(userMessage, chatHistory, userProfile)

	// Call AI
	groqMessages := s.convertToGroqMessages(messages)
	aiResponse, err := s.GroqClient.GetChatCompletion(ctx, groqMessages)
	if err != nil {
		log.Printf("AI call failed: %v", err)
		return &models.JobAIResponse{
			Message: "Sorry, I'm having trouble connecting to the AI service. Please try again later.",
		}, nil
	}

	// Extract job search criteria from AI response
	searchCriteria := s.extractJobSearchCriteria(aiResponse.Content, userProfile)

	// If criteria is found, perform job search
	if searchCriteria != nil {
		jobs, msg, err := s.JobService.GetCuratedJobs(
			searchCriteria.Field,
			searchCriteria.LookingFor,
			searchCriteria.Experience,
			searchCriteria.Skills,
			searchCriteria.Language,
		)

		if err == nil {
			// Create a combined response with AI message and job results
			finalResponse := fmt.Sprintf("%s\n\n%s", aiResponse.Content, msg)
			
			// Save to chat history
			response := s.saveChatHistory(ctx, userID, chatID, userMessage, finalResponse, searchCriteria, jobs)
			response.Jobs = jobs
			return response, nil
		}
	}

	// If no search criteria found or search failed, return just the AI response
	response := s.saveChatHistory(ctx, userID, chatID, userMessage, aiResponse.Content, nil, nil)
	return response, nil
}

func (s *JobAIService) extractJobSearchCriteria(aiResponse string, userProfile *models.User) *dto.JobSearchCriteriaDTO {
	// Look for JSON pattern in the AI response
	re := regexp.MustCompile(`\{[^{}]*\"experience\"[^{}]*\"field\"[^{}]*\"language\"[^{}]*\"looking_for\"[^{}]*\"skills\"[^{}]*\}`)
	matches := re.FindStringSubmatch(aiResponse)
	
	if len(matches) == 0 {
		return nil
	}

	var criteria dto.JobSearchCriteriaDTO
	err := json.Unmarshal([]byte(matches[0]), &criteria)
	if err != nil {
		log.Printf("Failed to parse job search criteria: %v", err)
		return nil
	}

	// Enhance with user profile data if available
	if userProfile != nil {
		if len(criteria.Skills) == 0 && len(userProfile.Skills) > 0 {
			criteria.Skills = userProfile.Skills
		}
		
		if criteria.Experience == "" && *userProfile.YearsExperience > 0 {
			if *userProfile.YearsExperience < 3 {
				criteria.Experience = "entry-level"
			} else if *userProfile.YearsExperience < 7 {
				criteria.Experience = "mid-level"
			} else {
				criteria.Experience = "senior"
			}
		}
	}

	return &criteria
}

func (s *JobAIService) prepareAIMessages(userMessage string, history []models.JobChatMessage, userProfile *models.User) []models.AIMessage {
	messages := []models.AIMessage{
		{
			Role: "system",
			Content: `You are a job search assistant. Your task is to extract job search criteria from user messages and return it in JSON format.

IMPORTANT: When the user provides job search criteria, you MUST respond with ONLY a JSON object containing these fields:
{
  "experience": "entry-level/mid-level/senior",
  "field": "software development/design/marketing/etc",
  "language": "en/am",
  "looking_for": "local/remote/freelance",
  "skills": ["JavaScript", "Python", "React", "etc"]
}

If the user doesn't provide complete information, ask for the missing details but still return the JSON with available fields.

Examples:
User: "I'm looking for remote software jobs"
Response: {"experience":"","field":"software development","language":"en","looking_for":"remote","skills":[]}

User: "I need local marketing jobs with 5 years experience"
Response: {"experience":"mid-level","field":"marketing","language":"en","looking_for":"local","skills":[]}

User: "JavaScript React jobs in Addis Ababa"
Response: {"experience":"","field":"software development","language":"en","looking_for":"local","skills":["JavaScript","React"]}`,
		},
	}

	// Add chat history
	for _, msg := range history {
		messages = append(messages, models.AIMessage{
			Role:    msg.Role,
			Content: msg.Message,
		})
	}

	// Add current user message
	messages = append(messages, models.AIMessage{
		Role:    "user",
		Content: userMessage,
	})

	return messages
}

func (s *JobAIService) convertToGroqMessages(messages []models.AIMessage) []dto.GroqAIMessageDTO {
	var groqMessages []dto.GroqAIMessageDTO
	for _, msg := range messages {
		groqMessages = append(groqMessages, dto.GroqAIMessageDTO{
			Role:    msg.Role,
			Content: msg.Content,
		})
	}
	return groqMessages
}

func (s *JobAIService) saveChatHistory(ctx context.Context, userID string, chatID string, userMessage string, aiResponse string, criteria *dto.JobSearchCriteriaDTO, jobs []models.Job) *models.JobAIResponse {
	response := &models.JobAIResponse{
		Message: aiResponse,
	}

	userMsg := models.JobChatMessage{
		Role:      "user",
		Message:   userMessage,
		Timestamp: time.Now(),
	}

	assistantMsg := models.JobChatMessage{
		Role:      "assistant",
		Message:   aiResponse,
		Timestamp: time.Now(),
	}

	var err error
	if chatID == "" {
		// Create new chat
		query := map[string]any{
			"field":       "",
			"looking_for": "",
			"skills":      []string{},
			"experience":  "",
			"language":    "en",
		}

		// Update query if criteria is available
		if criteria != nil {
			query["field"] = criteria.Field
			query["looking_for"] = criteria.LookingFor
			query["skills"] = criteria.Skills
			query["experience"] = criteria.Experience
			query["language"] = criteria.Language
		}

		chatID, err = s.JobChatRepo.CreateJobChat(ctx, userID, query, jobs, []models.JobChatMessage{userMsg, assistantMsg})
		if err != nil {
			log.Printf("Failed to create chat: %v", err)
		} else {
			response.ChatID = chatID
		}
	} else {
		// Append to existing chat
		err = s.JobChatRepo.AppendMessage(ctx, chatID, userMsg)
		if err != nil {
			log.Printf("Failed to append user message: %v", err)
		}
		err = s.JobChatRepo.AppendMessage(ctx, chatID, assistantMsg)
		if err != nil {
			log.Printf("Failed to append assistant message: %v", err)
		}
		response.ChatID = chatID
	}

	return response
}