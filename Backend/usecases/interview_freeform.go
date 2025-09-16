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
					"session_type": {
						Type:        "string",
						Description: "Type of interview session: general, technical, or behavioral.",
					},
				},
				Required: []string{"answer", "question", "session_type"},
			},
		},
	},
	{
		Type: "function",
		Function: services.AIToolFunction{
			Name:        "provide_interview_advice",
			Description: "Provides interview advice and tips based on the session context.",
			Parameters: services.AIToolFunctionParameters{
				Type: "object",
				Properties: map[string]services.AIToolProperty{
					"topic": {
						Type:        "string",
						Description: "The interview topic to provide advice about.",
					},
					"session_context": {
						Type:        "string",
						Description: "The session type context: general, technical, or behavioral.",
					},
				},
				Required: []string{"topic", "session_context"},
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
	var sessionDescription string
	switch sessionType {
	case "technical":
		sessionDescription = "technical interview practice focusing on programming, system design, and technical problem-solving"
	case "behavioral":
		sessionDescription = "behavioral interview practice focusing on STAR method, teamwork, and soft skills"
	default:
		sessionDescription = "general interview practice covering common questions and career discussions"
	}

	systemPrompt := fmt.Sprintf(`You are JobMate's Interview Coach, a specialized AI assistant for %s with young job seekers in Ethiopia.

Current Session: %s
Question Progress: %d

Your dual role:
1. **Interview Practice**: Ask relevant %s questions and provide feedback on answers
2. **Interview Advice**: Answer user questions about interview preparation, tips, and strategies

Session-Specific Focus:
- %s questions and scenarios
- Relevant advice for %s interview contexts
- Ethiopian workplace culture insights

MANDATORY TOOL USAGE - YOU MUST FOLLOW THESE RULES:
- If user requests ANY type of question, you MUST call get_next_question tool immediately - DO NOT provide generic advice
- If user provides an answer to evaluate, you MUST call evaluate_answer tool - DO NOT give feedback without using the tool
- If user asks for advice or tips, you MUST call provide_interview_advice tool
- NEVER provide interview questions or advice without using the appropriate tools
- Your response should ONLY come from tool outputs, not generic knowledge

Guidelines:
- When user asks for advice, provide helpful tips and examples
- When conducting practice, ask one question at a time and give feedback
- For behavioral questions only: mention STAR method (Situation, Task, Action, Result)
- For technical questions: focus on technical skills, no STAR method needed
- Be encouraging but honest in feedback
- Keep responses concise and actionable
- Speak in the same language as the user
- NEVER mention tool names or internal processes to the user
- Provide natural, conversational responses
- Avoid repetitive responses - vary your language and approach`, sessionDescription, sessionType, currentQuestion, sessionType, sessionType, sessionType)

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
			args, err := tc.Function.GetArgumentsAsMap()
			if err != nil {
				toolOutput = "Error parsing function arguments"
				break
			}
			requestedSessionType, _ := args["session_type"].(string)
			if requestedSessionType == "" {
				requestedSessionType = sessionType
			}
			
			question := u.generateSessionQuestion(requestedSessionType, messages, currentQuestion)
			toolOutput = fmt.Sprintf("Here's your next %s interview question: %s", requestedSessionType, question)

		case "evaluate_answer":
			args, err := tc.Function.GetArgumentsAsMap()
			if err != nil {
				toolOutput = fmt.Sprintf("Error parsing function arguments: %v", err)
				break
			}
			answer, _ := args["answer"].(string)
			question, _ := args["question"].(string)
			evalSessionType, _ := args["session_type"].(string)
			if evalSessionType == "" {
				evalSessionType = sessionType
			}

			feedback := u.evaluateAnswer(answer, question, evalSessionType)
			toolOutput = fmt.Sprintf("Answer Evaluation:\n%s", feedback)

		case "provide_interview_advice":
			args, err := tc.Function.GetArgumentsAsMap()
			if err != nil {
				toolOutput = "Error parsing function arguments"
				break
			}
			topic, _ := args["topic"].(string)
			context, _ := args["session_context"].(string)
			if context == "" {
				context = sessionType
			}
			
			advice := u.provideContextualAdvice(topic, context)
			toolOutput = advice

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

func (u *InterviewFreeformUsecase) generateSessionQuestion(sessionType string, messages []models.InterviewFreeformMessage, currentQuestion int) string {
	generalQuestions := []string{
		"Tell me about yourself and your career goals.",
		"Why are you interested in this position?",
		"What are your greatest strengths?",
		"Describe a challenging situation you faced and how you handled it.",
		"Where do you see yourself in 5 years?",
		"Why should we hire you?",
		"What motivates you in your work?",
	}
	
	technicalQuestions := []string{
		"Describe your experience with your primary programming language.",
		"How do you approach debugging a complex technical issue?",
		"Tell me about a challenging technical project you've worked on.",
		"How do you stay updated with new technologies?",
		"Explain a technical concept to someone without a technical background.",
		"How do you ensure code quality in your projects?",
		"Describe your experience with version control and collaboration.",
	}
	
	behavioralQuestions := []string{
		"Tell me about a time you had to deal with a difficult colleague.",
		"Describe a situation where you had to meet a tight deadline.",
		"How do you handle constructive criticism?",
		"Tell me about a time you made a mistake and how you handled it.",
		"Describe a situation where you had to adapt to change.",
		"How do you prioritize tasks when everything seems urgent?",
		"Tell me about a time you went above and beyond your job requirements.",
	}
	
	var questions []string
	switch sessionType {
	case "technical":
		questions = technicalQuestions
	case "behavioral":
		questions = behavioralQuestions
	default:
		questions = generalQuestions
	}
	
	questionIndex := currentQuestion % len(questions)
	return questions[questionIndex]
}

func (u *InterviewFreeformUsecase) provideContextualAdvice(topic string, sessionContext string) string {
	contextPrefix := ""
	switch sessionContext {
	case "technical":
		contextPrefix = "For technical interviews: "
	case "behavioral":
		contextPrefix = "For behavioral interviews: "
	default:
		contextPrefix = "For general interviews: "
	}
	
	switch strings.ToLower(topic) {
	case "strengths":
		if sessionContext == "technical" {
			return contextPrefix + "Focus on technical strengths like problem-solving, debugging skills, or specific technologies. Always provide concrete examples of projects or challenges you've solved."
		} else if sessionContext == "behavioral" {
			return contextPrefix + "Emphasize soft skills like leadership, teamwork, communication. Use the STAR method to structure your examples."
		}
		return contextPrefix + "Choose 2-3 key strengths relevant to the role. Always back them up with specific examples and explain how they benefit the employer."
		
	case "weaknesses":
		return contextPrefix + "Choose a real weakness that won't disqualify you. Show self-awareness and demonstrate concrete steps you're taking to improve. Always end with progress made."
		
	case "star method":
		return "STAR Method: Situation (context), Task (what needed to be done), Action (what you did), Result (outcome). Use this for all behavioral questions to provide structured, complete answers."
		
	case "preparation":
		if sessionContext == "technical" {
			return contextPrefix + "Review coding fundamentals, practice problem-solving, prepare to explain your projects in detail, and be ready for technical challenges or whiteboarding."
		}
		return contextPrefix + "Research the company, prepare STAR stories, practice common questions, prepare thoughtful questions to ask, and review your resume thoroughly."
		
	default:
		return fmt.Sprintf("%sI can help with specific interview topics like strengths, weaknesses, STAR method, preparation tips, and more. What would you like to know about?", contextPrefix)
	}
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


