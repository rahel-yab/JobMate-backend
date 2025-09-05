package usecases

import (
	"context"
	"fmt"
	"strings"
	"time"

	repositories "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/repositories"
	services "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/services"
	usecaseInterfaces "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/usecases"
	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
)

// CV-specific tools for AI
var cvChatTools = []services.AITool{
	{
		Type: "function",
		Function: services.AIToolFunction{
			Name:        "analyze_cv",
			Description: "Analyzes the user's CV for strengths, weaknesses, and improvement suggestions.",
			Parameters: services.AIToolFunctionParameters{
				Type: "object",
				Properties: map[string]services.AIToolProperty{
					"cv_id": {
						Type:        "string",
						Description: "The ID of the CV to analyze.",
					},
				},
				Required: []string{},
			},
		},
	},
	{
		Type: "function",
		Function: services.AIToolFunction{
			Name:        "suggest_cv_improvements",
			Description: "Provides specific suggestions to improve the CV based on job market trends.",
			Parameters: services.AIToolFunctionParameters{
				Type: "object",
				Properties: map[string]services.AIToolProperty{
					"target_field": {
						Type:        "string",
						Description: "The target job field for CV optimization.",
					},
				},
				Required: []string{},
			},
		},
	},
}

type cvChatUsecase struct {
	CVChatRepository repositories.ICVChatRepository
	CVUsecase        usecaseInterfaces.ICVUsecase
	AIService        services.IAIService
}

func NewCVChatUsecase(
	cvChatRepo repositories.ICVChatRepository,
	cvUsecase usecaseInterfaces.ICVUsecase,
	aiService services.IAIService,
) usecaseInterfaces.ICVChatUsecase {
	return &cvChatUsecase{
		CVChatRepository: cvChatRepo,
		CVUsecase:        cvUsecase,
		AIService:        aiService,
	}
}

func (u *cvChatUsecase) SendMessage(ctx context.Context, userID string, message string, cvID string, chatID string) (*models.CVChatMessage, error) {
	// Find or create CV chat session
	chats, err := u.CVChatRepository.GetCVChatsByUserID(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("failed to get user CV chats: %w", err)
	}

	if chatID == "" {
		if len(chats) == 0 {
			// Create new chat session
			chatID, err = u.CVChatRepository.CreateCVChat(ctx, userID, cvID)
			if err != nil {
				return nil, fmt.Errorf("failed to create CV chat: %w", err)
			}
		} else {
			// Use the most recent chat
			chatID = chats[len(chats)-1].ID
		}
	}

	// Save user message
	userMessage := models.CVChatMessage{
		Role:      "user",
		Content:   message,
		Timestamp: time.Now(),
	}

	err = u.CVChatRepository.AppendMessage(ctx, chatID, userMessage)
	if err != nil {
		return nil, fmt.Errorf("failed to save user message: %w", err)
	}

	// Get chat history for context
	chat, err := u.CVChatRepository.GetCVChatByID(ctx, chatID)
	if err != nil {
		return nil, fmt.Errorf("failed to get chat history: %w", err)
	}

	// Build AI messages with CV-specific system prompt
	aiMessages := u.buildCVAIMessages(chat.Messages, cvID)
	fmt.Print("cvID", cvID)

	// Call AI with CV-specific tools
	aiResponse, err := u.AIService.GetChatCompletion(ctx, aiMessages, cvChatTools)
	if err != nil {
		fmt.Printf("Groq API Error: %v\n", err) // Debug logging
		return u.createFallbackResponse(ctx, chatID, err)
	}

	// Handle tool calls if any
	if len(aiResponse.ToolCalls) > 0 {
		return u.handleCVToolCalls(ctx, chatID, aiResponse.ToolCalls, chat.Messages, cvID)
	}

	// Save AI response
	aiMessage := models.CVChatMessage{
		Role:      "assistant",
		Content:   strings.TrimSpace(aiResponse.Content),
		Timestamp: time.Now(),
	}

	err = u.CVChatRepository.AppendMessage(ctx, chatID, aiMessage)
	if err != nil {
		return nil, fmt.Errorf("failed to save AI message: %w", err)
	}

	return &aiMessage, nil
}

func (u *cvChatUsecase) CreateCVChatSession(ctx context.Context, userID string, cvID string) (string, error) {
	return u.CVChatRepository.CreateCVChat(ctx, userID, cvID)
}

func (u *cvChatUsecase) GetChatHistory(ctx context.Context, chatID string) (*models.CVChat, error) {
	return u.CVChatRepository.GetCVChatByID(ctx, chatID)
}

func (u *cvChatUsecase) GetChatHistoryWithLimit(ctx context.Context, chatID string, limit, offset int) (*models.CVChat, error) {
	chat, err := u.CVChatRepository.GetCVChatByID(ctx, chatID)
	if err != nil {
		return nil, err
	}

	// Apply pagination to messages (return most recent messages)
	totalMessages := len(chat.Messages)
	if totalMessages == 0 {
		return chat, nil
	}

	// Calculate start position from the end
	start := totalMessages - offset - limit
	if start < 0 {
		start = 0
	}

	end := totalMessages - offset
	if end <= 0 {
		// Return empty messages if offset is beyond available messages
		chat.Messages = []models.CVChatMessage{}
		return chat, nil
	}

	// Slice the messages array to get the most recent messages
	chat.Messages = chat.Messages[start:end]
	return chat, nil
}

func (u *cvChatUsecase) GetUserCVChats(ctx context.Context, userID string) ([]*models.CVChat, error) {
	return u.CVChatRepository.GetCVChatsByUserID(ctx, userID)
}

// buildCVAIMessages creates AI messages with CV-specific system prompt
// buildCVAIMessages creates AI messages with CV-specific system prompt including CV ID
func (u *cvChatUsecase) buildCVAIMessages(messages []models.CVChatMessage, cvID string) []services.AIMessage {
	// CV-specific system prompt with CV ID context
	systemPrompt := `You are JobMate's CV Expert, a specialized AI assistant focused on CV review, optimization, and career guidance for young job seekers in Ethiopia. 

Your expertise includes:
- CV structure and formatting best practices
- ATS (Applicant Tracking System) optimization
- Skills gap analysis and recommendations
- Industry-specific CV customization
- Ethiopian job market insights

Guidelines:
- Keep responses concise and actionable
- Provide specific, practical advice
- Focus on CV improvement and career development
- Be encouraging and supportive
- Speak in the same language as the user
- Reference Ethiopian job market context when relevant

Current CV Context: The user is discussing their CV with ID: ` + cvID + `

If the user asks to analyze their CV, you MUST use the 'analyze_cv' tool with the provided CV ID so that it can call the dedicated endpooitn for `

	aiMessages := []services.AIMessage{
		{Role: "system", Content: systemPrompt},
	}

	// Add conversation history
	for _, msg := range messages {
		aiMessages = append(aiMessages, services.AIMessage{
			Role:    msg.Role,
			Content: msg.Content,
		})
	}

	return aiMessages
}

// handleCVToolCalls processes CV-specific tool calls
func (u *cvChatUsecase) handleCVToolCalls(ctx context.Context, chatID string, toolCalls []services.ToolCall, messages []models.CVChatMessage, cvID string) (*models.CVChatMessage, error) {
	var toolResponses []services.AIMessage

	for _, tc := range toolCalls {
		var toolOutput string
		var err error

		switch tc.Function.Name {
		case "analyze_cv":
			args, err := tc.Function.GetArgumentsAsMap()
			if err != nil {
				toolOutput = "Error parsing CV analysis arguments"
			} else {
				cvID, ok := args["cv_id"].(string)
				if !ok || cvID == "" {
					toolOutput = "Please upload a CV first to get personalized analysis and feedback."
				} else {
					analysisResult, analyzeErr := u.CVUsecase.Analyze(ctx, cvID)
					if analyzeErr != nil {
						err = fmt.Errorf("failed to analyze CV: %w", analyzeErr)
						toolOutput = "Failed to analyze CV. Please try again."
					} else {
						var skillGaps []string
						for _, sg := range analysisResult.SkillGaps {
							skillGaps = append(skillGaps, sg.SkillName)
						}
						toolOutput = fmt.Sprintf("CV Analysis:\n✅ Strengths: %s\n⚠️ Areas for Improvement: %s\n📚 Skill Gaps: %s",
							analysisResult.CVFeedback.Strengths,
							analysisResult.CVFeedback.Weaknesses,
							strings.Join(skillGaps, ", "))
					}
				}
			}

		case "suggest_cv_improvements":
			args, err := tc.Function.GetArgumentsAsMap()
			if err != nil {
				toolOutput = "Error parsing improvement suggestions arguments"
			} else {
				targetField, _ := args["target_field"].(string)
				toolOutput = fmt.Sprintf("CV Improvement Suggestions for %s field:\n• Use action verbs and quantifiable achievements\n• Tailor keywords to job descriptions\n• Keep format clean and ATS-friendly\n• Highlight relevant skills and experience\n• Include Ethiopian context and local experience", targetField)
			}

		default:
			err = fmt.Errorf("unknown CV tool: %s", tc.Function.Name)
		}

		if err != nil {
			toolOutput = fmt.Sprintf("Error: %s", err.Error())
		}

		toolResponses = append(toolResponses, services.AIMessage{
			Role:       "tool",
			Content:    toolOutput,
			ToolCallID: tc.ID,
		})
	}

	// Second AI call with tool results
	finalMessages := u.buildCVAIMessages(messages, cvID)
	finalMessages = append(finalMessages, toolResponses...)

	finalResponse, err := u.AIService.GetChatCompletion(ctx, finalMessages, nil)
	if err != nil {
		return u.createFallbackResponse(ctx, chatID, err)
	}

	// Save final AI response
	aiMessage := models.CVChatMessage{
		Role:      "assistant",
		Content:   strings.TrimSpace(finalResponse.Content),
		Timestamp: time.Now(),
	}

	err = u.CVChatRepository.AppendMessage(ctx, chatID, aiMessage)
	if err != nil {
		return nil, fmt.Errorf("failed to save AI response: %w", err)
	}

	return &aiMessage, nil
}

func (u *cvChatUsecase) createFallbackResponse(ctx context.Context, chatID string, aiErr error) (*models.CVChatMessage, error) {
	fallbackMessage := "I'm experiencing technical difficulties. Please try again in a moment."

	aiMessage := models.CVChatMessage{
		Role:      "assistant",
		Content:   fallbackMessage,
		Timestamp: time.Now(),
	}

	// Try to save fallback message
	_ = u.CVChatRepository.AppendMessage(ctx, chatID, aiMessage)

	return &aiMessage, nil
}
