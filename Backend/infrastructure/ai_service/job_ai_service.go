package ai_service

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"regexp"
	"strings"
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
	searchCriteria, aiTextResponse := s.extractJobSearchCriteriaAndResponse(aiResponse.Content, userProfile)

	// If criteria is found and complete, perform job search
	var jobs []models.Job
	var searchMsg string
	
	if searchCriteria != nil && s.isCriteriaComplete(searchCriteria) {
		jobs, searchMsg, err = s.JobService.GetCuratedJobs(
			searchCriteria.Field,
			searchCriteria.LookingFor,
			searchCriteria.Experience,
			searchCriteria.Skills,
			searchCriteria.Language,
		)

		if err != nil {
			log.Printf("Job search failed: %v", err)
			searchMsg = "I couldn't find any current job openings matching your criteria. Please try different search terms or check back later."
		}
	}

	// Combine AI response with job search results
	finalResponse := s.formatFinalResponse(aiTextResponse, searchMsg, jobs, searchCriteria)

	// Save to chat history
	response := s.saveChatHistory(ctx, userID, chatID, userMessage, finalResponse, searchCriteria, jobs)
	response.Jobs = jobs
	
	return response, nil
}

func (s *JobAIService) extractJobSearchCriteriaAndResponse(aiResponse string, userProfile *models.User) (*dto.JobSearchCriteriaDTO, string) {
	// Look for JSON pattern in the AI response
	re := regexp.MustCompile(`\{[^{}]*\"experience\"[^{}]*\"field\"[^{}]*\"language\"[^{}]*\"looking_for\"[^{}]*\"skills\"[^{}]*\}`)
	matches := re.FindStringSubmatch(aiResponse)
	
	var criteria *dto.JobSearchCriteriaDTO
	textResponse := aiResponse

	if len(matches) > 0 {
		// Extract JSON and remove it from the text response
		jsonStr := matches[0]
		textResponse = strings.Replace(aiResponse, jsonStr, "", 1)
		textResponse = strings.TrimSpace(textResponse)
		
		var criteriaData dto.JobSearchCriteriaDTO
		err := json.Unmarshal([]byte(jsonStr), &criteriaData)
		if err != nil {
			log.Printf("Failed to parse job search criteria: %v", err)
		} else {
			criteria = &criteriaData
			
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
		}
	}

	return criteria, textResponse
}

func (s *JobAIService) isCriteriaComplete(criteria *dto.JobSearchCriteriaDTO) bool {
	return criteria.Field != "" && criteria.LookingFor != ""
}

func (s *JobAIService) formatFinalResponse(aiTextResponse, searchMsg string, jobs []models.Job, criteria *dto.JobSearchCriteriaDTO) string {
	if aiTextResponse == "" && criteria != nil {
		// If AI only returned JSON, create a friendly response
		aiTextResponse = fmt.Sprintf("I found your job preferences: %s %s position", criteria.Experience, criteria.Field)
		if len(criteria.Skills) > 0 {
			aiTextResponse += fmt.Sprintf(" with skills in %s", strings.Join(criteria.Skills, ", "))
		}
	}

	finalResponse := aiTextResponse
	
	if searchMsg != "" {
		if finalResponse != "" {
			finalResponse += "\n\n" + searchMsg
		} else {
			finalResponse = searchMsg
		}
	}

	if len(jobs) == 0 && criteria != nil && s.isCriteriaComplete(criteria) {
		finalResponse += "\n\nNo current job openings were found. You might want to:"
		finalResponse += "\n• Try different search terms"
		finalResponse += "\n• Broaden your location preference"
		finalResponse += "\n• Check back in a few days for new postings"
	}

	return finalResponse
}

func (s *JobAIService) prepareAIMessages(userMessage string, history []models.JobChatMessage, userProfile *models.User) []models.AIMessage {
	messages := []models.AIMessage{
		{
			Role: "system",
			Content: `You are a helpful job search assistant. Your task is to:

				1. Extract job search criteria from user messages
				2. Return a JSON object with the criteria
				3. Provide helpful, natural language responses

				CRITICAL: You MUST include BOTH:
				- A natural language response to the user
				- A JSON object with the extracted criteria

				JSON FORMAT:
				{
				"experience": "entry-level/mid-level/senior",
				"field": "job field",
				"language": "en/am", 
				"looking_for": "local/remote/freelance",
				"skills": ["skill1", "skill2"]
				}

				EXAMPLES:
				User: "I want remote software jobs with Python"
				Response: "Great! I'll search for remote Python software jobs for you.{\"experience\":\"\",\"field\":\"software development\",\"language\":\"en\",\"looking_for\":\"remote\",\"skills\":[\"Python\"]}"

				User: "I have 5 years experience in marketing"
				Response: "Thanks for sharing your experience! What type of marketing position are you looking for (local, remote, or freelance)?{\"experience\":\"mid-level\",\"field\":\"marketing\",\"language\":\"en\",\"looking_for\":\"\",\"skills\":[]}"

				Always be helpful and guide the user to provide missing information.`,
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