package ai_service

import (
	"context"
	"fmt"
	"log"
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
    aiResponse, err := s.GroqClient.GetChatCompletion(ctx, groqMessages, s.getJobSearchTools())
    if err != nil {
        log.Printf("AI call failed: %v", err)
        return &models.JobAIResponse{
            Message: "Sorry, I'm having trouble connecting to the AI service. Please try again later.",
        }, nil
    }

    // Parse AI response and execute actions
    return s.processAIResponse(ctx, userID, aiResponse, userMessage, chatID)
}

func (s *JobAIService) prepareAIMessages(userMessage string, history []models.JobChatMessage, userProfile *models.User) []models.AIMessage {
    messages := []models.AIMessage{
        {
            Role: "system",
            Content: `You are a job search assistant. STRICTLY follow these rules:

                CRITICAL INSTRUCTION: When user provides job search criteria (field, location preference, skills, experience), you MUST call the search_jobs function immediately.

                REQUIRED FIELDS FOR SEARCH: field, looking_for
                OPTIONAL FIELDS: skills, experience, language

                EXAMPLES OF WHEN TO CALL search_jobs:
                - User: "I want software jobs" → Ask for looking_for (remote/local/freelance)
                - User: "remote software jobs" → CALL search_jobs with field=software, looking_for=remote
                - User: "I need JavaScript remote jobs with React" → CALL search_jobs with field=software, looking_for=remote, skills=[JavaScript, React]

                DO NOT ask unnecessary follow-up questions. Call search_jobs as soon as you have field and looking_for.`,
        },
    }
    
    // Add chat history
    for _, msg := range history {
        messages = append(messages, models.AIMessage{
            Role:    msg.Role,
            Content: msg.Message,
        })
    }

    // Add user profile context if available
    if userProfile != nil && len(userProfile.Skills) > 0 {
        profileContext := fmt.Sprintf("User profile available: Skills: %v, Experience: %d years.",  
            userProfile.Skills, userProfile.YearsExperience)
        messages = append(messages, models.AIMessage{
            Role:    "system",
            Content: profileContext,
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

// infrastructure/ai_service/job_ai_service.go
func (s *JobAIService) getJobSearchTools() []dto.GroqToolDTO {
    return []dto.GroqToolDTO{
        {
            Type: "function",
            Function: dto.GroqToolFunctionDTO{
                Name:        "search_jobs",
                Description: "Search for jobs based on criteria",
                Parameters: map[string]interface{}{
                    "type": "object",
                    "properties": map[string]interface{}{
                        "field": map[string]interface{}{
                            "type":        "string",
                            "description": "Job field/industry",
                        },
                        "looking_for": map[string]interface{}{
                            "type":        "string",
                            "description": "local, remote, or freelance",
                            "enum":        []string{"local", "remote", "freelance"},
                        },
                        "skills": map[string]interface{}{
                            "type":        "array",
                            "description": "Required skills",
                            "items": map[string]interface{}{
                                "type": "string",
                            },
                        },
                        "experience": map[string]interface{}{
                            "type":        "string",
                            "description": "Experience level",
                        },
                        "language": map[string]interface{}{
                            "type":        "string",
                            "description": "en or am",
                            "enum":        []string{"en", "am"},
                        },
                    },
                    "required": []string{"field", "looking_for"},
                },
            },
        },
    }
}

func (s *JobAIService) processAIResponse(ctx context.Context, userID string, aiResponse *models.GroqAIMessage, userMessage string, chatID string) (*models.JobAIResponse, error) {
    log.Printf("AI Response Content: %s", aiResponse.Content)
    log.Printf("Number of Tool Calls: %d", len(aiResponse.ToolCalls))
    
    if aiResponse.ToolCalls != nil {
        for i, toolCall := range aiResponse.ToolCalls {
            log.Printf("Tool Call %d: %s", i, toolCall.Function.Name)
            log.Printf("Tool Arguments: %+v", toolCall.Function.Arguments)
        }
    }
    
    response := &models.JobAIResponse{
        Message: aiResponse.Content,
    }

    jobSearchPerformed := false

    // Check if AI called the search_jobs function
    if aiResponse.ToolCalls != nil {
        for _, toolCall := range aiResponse.ToolCalls {
            if toolCall.Function.Name == "search_jobs" {
                // Parse the function arguments
                if args, ok := toolCall.Function.Arguments.(map[string]interface{}); ok {
                    field := args["field"].(string)
                    lookingFor := args["looking_for"].(string)
                    
                    // Handle optional parameters
                    experience := ""
                    if exp, exists := args["experience"]; exists {
                        experience = exp.(string)
                    }
                    
                    skills := []string{}
                    if sk, exists := args["skills"]; exists {
                        if skillSlice, ok := sk.([]interface{}); ok {
                            for _, skill := range skillSlice {
                                skills = append(skills, skill.(string))
                            }
                        }
                    }
                    
                    language := "en" // default
                    if lang, exists := args["language"]; exists {
                        language = lang.(string)
                    }

                    // Search for jobs
                    jobs, msg, err := s.JobService.GetCuratedJobs(field, lookingFor, experience, skills, language)
                    if err != nil {
                        log.Printf("Job search failed: %v", err)
                        response.Message += "\n\nSorry, I couldn't find any jobs at the moment. Please try again later."
                    } else {
                        response.Jobs = jobs
                        response.Message += "\n\n" + msg
                        jobSearchPerformed = true  
                    }
                }
            }
        }
    }

    // Save to chat history
    userMsg := models.JobChatMessage{
        Role:      "user",
        Message:   userMessage,
        Timestamp: time.Now(),
    }

    assistantMsg := models.JobChatMessage{
        Role:      "assistant",
        Message:   response.Message,
        Timestamp: time.Now(),
    }

    var err error
    if chatID == "" {
        // Create new chat
        query := map[string]any{
            "field":       "", // You might want to capture these from the tool call
            "looking_for": "",
            "skills":      []string{},
            "experience":  "",
            "language":    "en",
        }
        
        // Update query if job search was performed
        if jobSearchPerformed && aiResponse.ToolCalls != nil {
            for _, toolCall := range aiResponse.ToolCalls {
                if toolCall.Function.Name == "search_jobs" {
                    if args, ok := toolCall.Function.Arguments.(map[string]interface{}); ok {
                        query["field"] = args["field"]
                        query["looking_for"] = args["looking_for"]
                        if exp, exists := args["experience"]; exists {
                            query["experience"] = exp
                        }
                        if sk, exists := args["skills"]; exists {
                            query["skills"] = sk
                        }
                        if lang, exists := args["language"]; exists {
                            query["language"] = lang
                        }
                    }
                }
            }
        }
        
        chatID, err = s.JobChatRepo.CreateJobChat(ctx, userID, query, response.Jobs, []models.JobChatMessage{userMsg, assistantMsg})
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

    return response, nil
}