package usecases

import (
	"context"
	"fmt"
	"log"
	"strings"
	"time"

	repo "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/repositories"
	service "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/services"
	usecase "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/usecases"
	model "github.com/tsigemariamzewdu/JobMate-backend/domain/models"
)

// CV-specific tools for AI
var cvChatTools = []service.AITool{
	{
		Type: "function",
		Function: service.AIToolFunction{
			Name:        "analyze_cv",
			Description: "Retrieves the existing analysis for the user's CV including strengths, weaknesses, skill gaps, and improvement suggestions.",
			Parameters: service.AIToolFunctionParameters{
				Type: "object",
				Properties: map[string]service.AIToolProperty{
					"cv_id": {
						Type:        "string",
						Description: "The ID of the CV to get analysis for. If not provided, uses the current chat's CV.",
					},
				},
				Required: []string{},
			},
		},
	},
	{
		Type: "function",
		Function: service.AIToolFunction{
			Name:        "suggest_cv_improvements",
			Description: "Provides specific suggestions to improve the CV based on job market trends.",
			Parameters: service.AIToolFunctionParameters{
				Type: "object",
				Properties: map[string]service.AIToolProperty{
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
	CVChatRepository repo.ICVChatRepository
	CVUsecase        usecase.ICVUsecase
	CVRepo           repo.CVRepository       // NEW: To get analyzed CV data
	FeedbackRepo     repo.FeedbackRepository // NEW: To get existing feedback
	SkillGapRepo     repo.SkillGapRepository // NEW: To get existing skill gaps
	AIService        service.IAIService
}

func NewCVChatUsecase(
	cvChatRepo repo.ICVChatRepository,
	cvUsecase usecase.ICVUsecase,
	cvRepo repo.CVRepository, // NEW
	feedbackRepo repo.FeedbackRepository, // NEW
	skillGapRepo repo.SkillGapRepository, // NEW
	aiService service.IAIService,
) usecase.ICVChatUsecase {
	return &cvChatUsecase{
		CVChatRepository: cvChatRepo,
		CVUsecase:        cvUsecase,
		CVRepo:           cvRepo,       // NEW
		FeedbackRepo:     feedbackRepo, // NEW
		SkillGapRepo:     skillGapRepo, // NEW
		AIService:        aiService,
	}
}

func (u *cvChatUsecase) SendMessage(ctx context.Context, userID string, message string, cvID string, chatID string) (*model.CVChatMessage, error) {
	log.Printf("[DEBUG] SendMessage called with userID=%s, cvID=%s, chatID=%s, message=%q", userID, cvID, chatID, message)

	// Find or create CV chat session
	chats, err := u.CVChatRepository.GetCVChatsByUserID(ctx, userID)
	if err != nil {
		log.Printf("[ERROR] Failed to get user CV chats: %v", err)
		return nil, fmt.Errorf("failed to get user CV chats: %w", err)
	}

	log.Printf("[DEBUG] Found %d chats for user %s", len(chats), userID)

	if chatID == "" {
		if len(chats) == 0 {
			// Create new chat session
			chatID, err = u.CVChatRepository.CreateCVChat(ctx, userID, cvID)
			if err != nil {
				log.Printf("[ERROR] Failed to create CV chat: %v", err)
				return nil, fmt.Errorf("failed to create CV chat: %w", err)
			}
			log.Printf("[DEBUG] Created new chat session with ID %s", chatID)
		} else {
			// Use the most recent chat
			chatID = chats[len(chats)-1].ID
			log.Printf("[DEBUG] Using most recent chat session with ID %s", chatID)
		}
	}

	// Save user message
	userMessage := model.CVChatMessage{
		Role:      "user",
		Content:   message,
		Timestamp: time.Now(),
	}
	log.Printf("[DEBUG] Appending user message to chatID=%s: %q", chatID, message)

	err = u.CVChatRepository.AppendMessage(ctx, chatID, userMessage)
	if err != nil {
		log.Printf("[ERROR] Failed to save user message: %v", err)
		return nil, fmt.Errorf("failed to save user message: %w", err)
	}

	// Get chat history for context
	chat, err := u.CVChatRepository.GetCVChatByID(ctx, chatID)
	if err != nil {
		log.Printf("[ERROR] Failed to get chat history for chatID=%s: %v", chatID, err)
		return nil, fmt.Errorf("failed to get chat history: %w", err)
	}
	log.Printf("[DEBUG] Retrieved chat history: %d messages", len(chat.Messages))

	// Build AI messages with CV-specific system prompt
	aiMessages := u.buildCVAIMessages(chat.Messages, cvID)
	log.Printf("[DEBUG] Built %d AI messages for chatID=%s", len(aiMessages), chatID)

	// Call AI with CV-specific tools
	aiResponse, err := u.AIService.GetChatCompletion(ctx, aiMessages, cvChatTools)
	if err != nil {
		log.Printf("[ERROR] AIService.GetChatCompletion failed: %v", err)
		return u.createFallbackResponse(ctx, chatID, err)
	}

	log.Printf("[DEBUG] AI response content length=%d, toolCalls=%d", len(aiResponse.Content), len(aiResponse.ToolCalls))

	// Handle tool calls if any
	if len(aiResponse.ToolCalls) > 0 {
		log.Printf("[DEBUG] Handling %d tool calls for chatID=%s", len(aiResponse.ToolCalls), chatID)
		return u.handleCVToolCalls(ctx, chatID, aiResponse.ToolCalls, chat.Messages, cvID)
	}

	// Save AI response
	aiMessage := model.CVChatMessage{
		Role:      "assistant",
		Content:   strings.TrimSpace(aiResponse.Content),
		Timestamp: time.Now(),
	}
	log.Printf("[DEBUG] Appending AI message to chatID=%s: %q", chatID, aiMessage.Content)

	err = u.CVChatRepository.AppendMessage(ctx, chatID, aiMessage)
	if err != nil {
		log.Printf("[ERROR] Failed to save AI message: %v", err)
		return nil, fmt.Errorf("failed to save AI message: %w", err)
	}

	return &aiMessage, nil
}


func (u *cvChatUsecase) CreateCVChatSession(ctx context.Context, userID string, cvID string) (string, error) {
	return u.CVChatRepository.CreateCVChat(ctx, userID, cvID)
}

func (u *cvChatUsecase) GetChatHistory(ctx context.Context, chatID string) (*model.CVChat, error) {
	return u.CVChatRepository.GetCVChatByID(ctx, chatID)
}

func (u *cvChatUsecase) GetChatHistoryWithLimit(ctx context.Context, chatID string, limit, offset int) (*model.CVChat, error) {
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
		chat.Messages = []model.CVChatMessage{}
		return chat, nil
	}

	// Slice the messages array to get the most recent messages
	chat.Messages = chat.Messages[start:end]
	return chat, nil
}

func (u *cvChatUsecase) GetUserCVChats(ctx context.Context, userID string) ([]*model.CVChat, error) {
	return u.CVChatRepository.GetCVChatsByUserID(ctx, userID)
}

// getExistingCVAnalysis fetches the already-generated analysis for a CV and formats it for the AI tool.
func (u *cvChatUsecase) getExistingCVAnalysis(ctx context.Context, cvID string) (string, error) {
	if cvID == "" {
		return "No CV ID provided. Please upload a CV first.", nil
	}

	// 1. Get the analyzed CV data
	cv, err := u.CVRepo.GetByID(ctx, cvID)
	if err != nil {
		return "", fmt.Errorf("failed to find CV: %w", err)
	}

	// Check if it has been analyzed
	if strings.TrimSpace(cv.Summary) == "" {
		return "The selected CV has not been analyzed yet. Please use the 'Analyze' feature first.", nil
	}

	// 2. Get the feedback for this CV
	feedback, err := u.FeedbackRepo.GetLatestByCVID(ctx, cvID)
	if err != nil {
		// Log the error but proceed, we can still use the CV data
		log.Printf("Warning: Could not fetch feedback for CV %s: %v", cvID, err)
		feedback = &model.CVFeedback{} // Use an empty struct to avoid nil panics
	}

	// 3. Get skill gaps for the user
	skillGaps, err := u.SkillGapRepo.GetByUserID(ctx, cv.UserID)
	if err != nil {
		log.Printf("Warning: Could not fetch skill gaps for user %s: %v", cv.UserID, err)
		skillGaps = []*model.SkillGap{}
	}

	// 4. Format the information into a cohesive summary for the AI tool
	var sb strings.Builder

	sb.WriteString("=== EXISTING CV ANALYSIS ===\n\n")
	sb.WriteString(fmt.Sprintf("CV Summary: %s\n\n", cv.Summary))

	if len(cv.ExtractedSkills) > 0 {
		sb.WriteString("Extracted Skills:\n")
		for i, skill := range cv.ExtractedSkills {
			sb.WriteString(fmt.Sprintf("  %d. %s\n", i+1, skill))
		}
		sb.WriteString("\n")
	}

	if len(cv.ExtractedExperience) > 0 {
		sb.WriteString("Extracted Experience:\n")
		for i, exp := range cv.ExtractedExperience {
			sb.WriteString(fmt.Sprintf("  %d. %s\n", i+1, exp))
		}
		sb.WriteString("\n")
	}

	if len(cv.ExtractedEducation) > 0 {
		sb.WriteString("Extracted Education:\n")
		for i, edu := range cv.ExtractedEducation {
			sb.WriteString(fmt.Sprintf("  %d. %s\n", i+1, edu))
		}
		sb.WriteString("\n")
	}

	sb.WriteString("Feedback:\n")
	sb.WriteString(fmt.Sprintf("  Strengths: %s\n", feedback.Strengths))
	sb.WriteString(fmt.Sprintf("  Weaknesses: %s\n", feedback.Weaknesses))
	sb.WriteString(fmt.Sprintf("  Improvement Suggestions: %s\n\n", feedback.ImprovementSuggestions))

	sb.WriteString("Identified Skill Gaps:\n")
	if len(skillGaps) == 0 {
		sb.WriteString("  No significant skill gaps identified.\n")
	} else {
		for i, gap := range skillGaps {
			sb.WriteString(fmt.Sprintf("  %d. %s (Current: %s, Recommended: %s, Importance: %s)\n",
				i+1, gap.SkillName, gap.CurrentLevel, gap.RecommendedLevel, gap.Importance))
			sb.WriteString(fmt.Sprintf("     Suggestion: %s\n", gap.ImprovementSuggestions))
		}
	}

	return sb.String(), nil
}

// buildCVAIMessages creates AI messages with CV-specific system prompt including CV ID
func (u *cvChatUsecase) buildCVAIMessages(messages []model.CVChatMessage, cvID string) []service.AIMessage {
	// CV-specific system prompt with CV ID context
	systemPrompt := `
You are JobMate's CV Expert, specializing in CV review, optimization, and career guidance for young job seekers in Ethiopia.

Your expertise: 
- CV structure & formatting
- ATS optimization
- Skills gap analysis
- Industry-specific tailoring
- Ethiopian job market insights

Guidelines:
- Be concise, practical, supportive.
- Match the user’s language.
- Always relate advice to Ethiopian job context when useful.

IMPORTANT TOOL RULES:
- For strengths, weaknesses, skill gaps, or analysis details → always call the 'analyze_cv' tool But you do not need a CV ID to call this tool if the user provides a CV ID use that but if not do not bother the user to provide CV ID just call the tool and it will fetch the latest cv of the user and gives you the skill gap,weakness strengths and etc.
  • This retrieves existing, pre-generated results (summary, skills, feedback, gaps).
  • After fetching, expand and explain in plain language.
- Do NOT re-analyze. If the user requests new/fresh analysis, politely tell them to use the app's "Analyze" feature.
- If CV ID not provided, Do not ask the user for CV ID .

In short:
- “Add more insights/details” → call 'analyze_cv' then elaborate.
- “Re-analyze” → instruct them to use the Analyze feature.
Current CV Context: CV ID = {cvID}
`

	aiMessages := []service.AIMessage{
		{Role: "system", Content: systemPrompt},
	}

	// Add conversation history
	for _, msg := range messages {
		aiMessages = append(aiMessages, service.AIMessage{
			Role:    msg.Role,
			Content: msg.Content,
		})
	}

	return aiMessages
}

// handleCVToolCalls processes CV-specific tool calls
func (u *cvChatUsecase) handleCVToolCalls(ctx context.Context, chatID string, toolCalls []service.ToolCall, messages []model.CVChatMessage, cvID string) (*model.CVChatMessage, error) {
	var toolResponses []service.AIMessage

	for _, tc := range toolCalls {
		var toolOutput string
		var err error

		switch tc.Function.Name {
		case "analyze_cv":
			// We are not re-analyzing, we are fetching the existing analysis.
			args, parseErr := tc.Function.GetArgumentsAsMap()
			if parseErr != nil {
				toolOutput = "Error parsing CV analysis arguments."
				break
			}

			// Use the provided CV ID, or fall back to the one from the chat context
			requestedCvID, _ := args["cv_id"].(string)
			if requestedCvID == "" {
				// If no CV ID was provided in the tool call, use the one from the current chat context.
				// This assumes the chat is already associated with a CV.
				requestedCvID = cvID
			}

			// Get the existing, pre-generated analysis
			analysisSummary, getErr := u.getExistingCVAnalysis(ctx, requestedCvID)
			if getErr != nil {
				toolOutput = fmt.Sprintf("Sorry, I couldn't retrieve the analysis for your CV. Please ensure it has been analyzed. Error: %s", getErr.Error())
			} else {
				toolOutput = analysisSummary
			}

		case "suggest_cv_improvements":
			args, parseErr := tc.Function.GetArgumentsAsMap()
			if parseErr != nil {
				toolOutput = "Error parsing improvement suggestions arguments"
				break
			}
			targetField, _ := args["target_field"].(string)
			if targetField == "" {
				targetField = "general"
			}
			toolOutput = fmt.Sprintf("CV Improvement Suggestions for %s field:\n• Use action verbs and quantifiable achievements\n• Tailor keywords to job descriptions\n• Keep format clean and ATS-friendly\n• Highlight relevant skills and experience\n• Include Ethiopian context and local experience", targetField)

		default:
			err = fmt.Errorf("unknown CV tool: %s", tc.Function.Name)
		}

		if err != nil {
			toolOutput = fmt.Sprintf("Error: %s", err.Error())
		}

		toolResponses = append(toolResponses, service.AIMessage{
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
	aiMessage := model.CVChatMessage{
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

func (u *cvChatUsecase) createFallbackResponse(ctx context.Context, chatID string, aiErr error) (*model.CVChatMessage, error) {
	fallbackMessage := "I'm experiencing technical difficulties. Please try again in a moment."

	aiMessage := model.CVChatMessage{
		Role:      "assistant",
		Content:   fallbackMessage,
		Timestamp: time.Now(),
	}

	// Try to save fallback message
	_ = u.CVChatRepository.AppendMessage(ctx, chatID, aiMessage)

	return &aiMessage, nil
}
