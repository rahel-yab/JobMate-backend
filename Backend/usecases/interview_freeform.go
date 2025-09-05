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


var freeformChatTools = []services.AITool{
	{
		Type: "function",
		Function: services.AIToolFunction{
			Name:        "get_next_question",
			Description: "Gets the next interview question based on session type and progress.",
			Parameters: services.AIToolFunctionParameters{
				Type: "object",
				Properties: map[string]services.AIToolProperty{
					"session_type": {
						Type:        "string",
						Description: "Type of interview session: general, technical, or behavioral.",
					},
				},
				Required: []string{"session_type"},
			},
		},
	},
	{
		Type: "function",
		Function: services.AIToolFunction{
			Name:        "evaluate_answer",
			Description: "Evaluates a candidate's answer and provides feedback.",
			Parameters: services.AIToolFunctionParameters{
				Type: "object",
				Properties: map[string]services.AIToolProperty{
					"answer": {
						Type:        "string",
						Description: "The candidate's answer to evaluate.",
					},
					"question": {
						Type:        "string",
						Description: "The interview question that was asked.",
					},
				},
				Required: []string{"answer", "question"},
			},
		},
	},
}

type InterviewFreeformUsecase struct {
	InterviewFreeformRepository repositories.IInterviewFreeformRepository
	AIService                   services.IAIService
}

func NewInterviewFreeformUsecase(
	interviewFreeformRepo repositories.IInterviewFreeformRepository,
	aiService services.IAIService,
) usecaseInterfaces.IInterviewFreeformUsecase {
	return &InterviewFreeformUsecase{
		InterviewFreeformRepository: interviewFreeformRepo,
		AIService:                   aiService,
	}
}

func (u *InterviewFreeformUsecase) SendMessage(ctx context.Context, userID string, message string, chatID string) (*models.InterviewFreeformMessage, error) {
	// Get chat history for context
	chat, err := u.InterviewFreeformRepository.GetInterviewChatByID(ctx, chatID)
	if err != nil {
		return nil, fmt.Errorf("failed to get chat: %w", err)
	}

	// Verify user owns this chat
	if chat.UserID != userID {
		return nil, fmt.Errorf("unauthorized access to chat")
	}

	// Save user message
	userMessage := models.InterviewFreeformMessage{
		Role:      "user",
		Content:   message,
		Timestamp: time.Now(),
	}

	_, err = u.InterviewFreeformRepository.AppendMessage(ctx, chatID, userMessage)
	if err != nil {
		return nil, fmt.Errorf("failed to save user message: %w", err)
	}

	// Build AI messages with interview context
	aiMessages := u.buildInterviewAIMessages(chat.Messages, chat.SessionType, 0)
	aiMessages = append(aiMessages, services.AIMessage{
		Role:    "user",
		Content: message,
	})

	// Get AI response with interview tools
	response, err := u.AIService.GetChatCompletion(ctx, aiMessages, freeformChatTools)
	if err != nil {
		return u.createFallbackResponse(ctx, chatID, err)
	}

	// Handle tool calls if present
	if len(response.ToolCalls) > 0 {
		return u.handleInterviewToolCalls(ctx, chatID, response.ToolCalls, chat.Messages, chat.SessionType, 0)
	}

	// Save AI response
	aiMessage := models.InterviewFreeformMessage{
		Role:      "assistant",
		Content:   strings.TrimSpace(response.Content),
		Timestamp: time.Now(),
	}

	savedAIMessage, err := u.InterviewFreeformRepository.AppendMessage(ctx, chatID, aiMessage)
	if err != nil {
		return nil, fmt.Errorf("failed to save AI response: %w", err)
	}

	return savedAIMessage, nil
}

func (u *InterviewFreeformUsecase) CreateInterviewSession(ctx context.Context, userID string, sessionType string) (string, error) {
	return u.InterviewFreeformRepository.CreateInterviewChat(ctx, userID, sessionType)
}

func (u *InterviewFreeformUsecase) GetChatHistory(ctx context.Context, chatID string) (*models.InterviewFreeformChat, error) {
	return u.InterviewFreeformRepository.GetInterviewChatByID(ctx, chatID)
}

func (u *InterviewFreeformUsecase) GetChatHistoryWithLimit(ctx context.Context, chatID string, limit, offset int) (*models.InterviewFreeformChat, error) {
	return u.InterviewFreeformRepository.GetInterviewChatByIDWithLimit(ctx, chatID, limit, offset)
}

func (u *InterviewFreeformUsecase) GetUserInterviewChats(ctx context.Context, userID string) ([]*models.InterviewFreeformChat, error) {
	return u.InterviewFreeformRepository.GetInterviewChatsByUserID(ctx, userID)
}

func (u *InterviewFreeformUsecase) GetNextQuestion(ctx context.Context, chatID string) (string, error) {
	return "Free-form chat mode - ask any interview-related question!", nil
}

func (u *InterviewFreeformUsecase) CompleteSession(ctx context.Context, chatID string) error {

	return nil
}

// buildInterviewAIMessages creates AI messages with interview-specific system prompt
func (u *InterviewFreeformUsecase) buildInterviewAIMessages(messages []models.InterviewFreeformMessage, sessionType string, currentQuestion int) []services.AIMessage {
	systemPrompt := fmt.Sprintf(`You are JobMate's Interview Coach, a specialized AI assistant focused on interview preparation and practice for young job seekers in Ethiopia.

Current Session: %s interview practice
Question Progress: %d

Your expertise includes:
- Conducting realistic mock interviews
- Providing constructive feedback on answers
- Teaching STAR method (Situation, Task, Action, Result)
- Helping with confidence building
- Ethiopian workplace culture insights

Guidelines:
- Act as a professional interviewer
- Ask follow-up questions when appropriate
- Provide specific feedback on answers
- Be encouraging but honest
- Help improve communication skills
- Keep responses concise and focused
- Speak in the same language as the user

Interview Flow:
1. Ask questions one at a time
2. Listen to answers and provide feedback
3. Move to next question or ask follow-ups
4. Conclude with overall feedback`, sessionType, currentQuestion)

	aiMessages := []services.AIMessage{
		{Role: "system", Content: systemPrompt},
	}

	for _, msg := range messages {
		aiMessages = append(aiMessages, services.AIMessage{
			Role:    msg.Role,
			Content: msg.Content,
		})
	}

	return aiMessages
}

// handleInterviewToolCalls processes interview-specific tool calls
func (u *InterviewFreeformUsecase) handleInterviewToolCalls(ctx context.Context, chatID string, toolCalls []services.ToolCall, messages []models.InterviewFreeformMessage, sessionType string, currentQuestion int) (*models.InterviewFreeformMessage, error) {
	var toolResponses []services.AIMessage

	for _, tc := range toolCalls {
		var toolOutput string
		var err error

		switch tc.Function.Name {
		case "get_next_question":
			toolOutput = "Here's a good interview question: Tell me about a challenging situation you faced and how you handled it."

		case "evaluate_answer":
			args, err := tc.Function.GetArgumentsAsMap()
			if err != nil {
				toolOutput = fmt.Sprintf("Error parsing function arguments: %v", err)
				break
			}
			answer, _ := args["answer"].(string)
			question, _ := args["question"].(string)

			feedback := u.evaluateAnswer(answer, question, sessionType)
			toolOutput = fmt.Sprintf("Answer Evaluation:\n%s", feedback)

		default:
			err = fmt.Errorf("unknown interview tool: %s", tc.Function.Name)
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
	finalMessages := u.buildInterviewAIMessages(messages, sessionType, currentQuestion)
	finalMessages = append(finalMessages, toolResponses...)

	finalResponse, err := u.AIService.GetChatCompletion(ctx, finalMessages, nil)
	if err != nil {
		return u.createFallbackResponse(ctx, chatID, err)
	}

	// Save final AI response
	aiMessage := models.InterviewFreeformMessage{
		Role:    "assistant",
		Content: strings.TrimSpace(finalResponse.Content),
		// QuestionIndex not needed for freeform messages
		Timestamp: time.Now(),
	}

	savedMessage, err := u.InterviewFreeformRepository.AppendMessage(ctx, chatID, aiMessage)
	if err != nil {
		return nil, fmt.Errorf("failed to save AI response: %w", err)
	}

	return savedMessage, nil
}

func (u *InterviewFreeformUsecase) evaluateAnswer(answer, question, sessionType string) string {
	answerLength := len(strings.TrimSpace(answer))

	feedback := "Feedback on your answer:\n"

	if answerLength < 50 {
		feedback += "• Try to provide more detailed examples\n"
	} else if answerLength > 500 {
		feedback += "• Consider being more concise\n"
	} else {
		feedback += "• Good length and detail\n"
	}

	if sessionType == "behavioral" && !strings.Contains(strings.ToLower(answer), "situation") {
		feedback += "• For behavioral questions, try using the STAR method (Situation, Task, Action, Result)\n"
	}

	feedback += "• Remember to speak confidently and maintain eye contact\n"
	feedback += "• Great job practicing!"

	return feedback
}

func (u *InterviewFreeformUsecase) createFallbackResponse(ctx context.Context, chatID string, aiErr error) (*models.InterviewFreeformMessage, error) {
	fallbackMessage := "I'm experiencing technical difficulties. Let's continue with the next question when ready."

	aiMessage := models.InterviewFreeformMessage{
		Role:      "assistant",
		Content:   fallbackMessage,
		Timestamp: time.Now(),
	}

	savedMessage, _ := u.InterviewFreeformRepository.AppendMessage(ctx, chatID, aiMessage)

	return savedMessage, nil
}

