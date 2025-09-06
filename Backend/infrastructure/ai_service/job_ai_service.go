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
            Content: `You are a job search assistant. ONLY help with job-related queries.
            
            STRICT RULES:
            1. Only respond to job search, career advice, employment questions
            2. If user asks about CV/resume, say: "Please use our CV analysis section for that"
            3. If user asks about interviews, say: "Check our interview practice section"
            4. For off-topic queries: "I'm here to help with job search only"
            
            JOB SEARCH FLOW:
            - If user wants job search, ask if they want to use their profile data
            - If yes, use their skills/experience from profile
            - If no, ask for: job field, location preference, skills, experience level
            - Then search jobs using available tools
            - Present results clearly`,
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
                Parameters: dto.GroqToolFunctionParametersDTO{
                    Type: "object",
                    Properties: map[string]dto.GroqToolPropertyDTO{
                        "field": {
                            Type:        "string",
                            Description: "Job field/industry",
                        },
                        "looking_for": {
                            Type:        "string",
                            Description: "local, remote, or freelance",
                        },
                        "skills": {
                            Type:        "array",
                            Description: "Required skills",
                            Items: &dto.GroqToolPropertyDTO{
                                Type: "string",
                            },
                        },
                        "experience": {
                            Type:        "string",
                            Description: "Experience level",
                        },
                        "language": {
                            Type:        "string",
                            Description: "en or am",
                        },
                    },
                    Required: []string{"field", "looking_for"},
                },
            },
        },
    }
}

func (s *JobAIService) processAIResponse(ctx context.Context, userID string, aiResponse *models.GroqAIMessage, userMessage string, chatID string) (*models.JobAIResponse, error) {
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
                    if err == nil {
                        response.Jobs = jobs
                        response.Message += "\n\n" + msg
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