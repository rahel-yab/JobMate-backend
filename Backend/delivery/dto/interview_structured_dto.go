package dto

import (
	"time"

	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
)

// Structured Interview DTOs
type StartStructuredInterviewRequest struct {
	Field            string `json:"field" binding:"required"`            // e.g., "software_engineering"
	PreferredLanguage string `json:"preferred_language" binding:"required"` // e.g., "en", "am", "or"
}

type StartStructuredInterviewResponse struct {
	ChatID            string `json:"chat_id"`
	Field             string `json:"field"`
	PreferredLanguage string `json:"preferred_language"`
	TotalQuestions    int    `json:"total_questions"`
	FirstQuestion     string `json:"first_question"`
	Message           string `json:"message"`
}


type SubmitInterviewAnswerRequest struct {
	Answer string `json:"answer" binding:"required"`
}

type InterviewStartRequest struct {
	Field       string                 `json:"field" binding:"required"`        // e.g., "software_engineering"
	UserProfile map[string]interface{} `json:"user_profile" binding:"required"` // experience, skills, position
}

type InterviewStartResponse struct {
	ChatID         string `json:"chat_id"`
	FirstQuestion  string `json:"first_question"`
	QuestionIndex  int    `json:"question_index"`
	TotalQuestions int    `json:"total_questions"`
	Message        string `json:"message"`
}

type InterviewAnswerRequest struct {
	ChatID string `json:"chat_id" binding:"required"`
	Answer string `json:"answer" binding:"required"`
}

type InterviewAnswerResponse struct {
	Feedback       string `json:"feedback"`
	NextQuestion   string `json:"next_question,omitempty"`
	QuestionIndex  int    `json:"question_index"`
	TotalQuestions int    `json:"total_questions"`
	IsCompleted    bool   `json:"is_completed"`
	CompletionMsg  string `json:"completion_message,omitempty"`
}

type StructuredInterviewChatResponse struct {
	ID            string    `json:"id"`
	Role          string    `json:"role"`
	Content       string    `json:"content"`
	QuestionIndex int       `json:"question_index"`
	Timestamp     time.Time `json:"timestamp"`
}

type StructuredInterviewSessionResponse struct {
	ChatID            string                            `json:"chat_id"`
	UserID            string                            `json:"user_id"`
	Field             string                            `json:"field"`
	PreferredLanguage string                            `json:"preferred_language"`
	UserProfile       map[string]interface{}            `json:"user_profile"`
	Questions         []string                          `json:"questions"`
	Messages          []StructuredInterviewChatResponse `json:"messages"`
	CurrentQuestion   int                               `json:"current_question"`
	IsCompleted       bool                              `json:"is_completed"`
	CreatedAt         time.Time                         `json:"created_at"`
	UpdatedAt         time.Time                         `json:"updated_at"`
}

type StructuredInterviewChatSummary struct {
	ChatID          string                 `json:"chat_id"`
	Field           string                 `json:"field"`
	UserProfile     map[string]interface{} `json:"user_profile"`
	CurrentQuestion int                    `json:"current_question"`
	TotalQuestions  int                    `json:"total_questions"`
	IsCompleted     bool                   `json:"is_completed"`
	LastMessage     string                 `json:"last_message"`
	CreatedAt       time.Time              `json:"created_at"`
	UpdatedAt       time.Time              `json:"updated_at"`
}

type UserStructuredInterviewChatsResponse struct {
	Chats []StructuredInterviewChatSummary `json:"chats"`
	Total int                              `json:"total"`
}

type ResumeStructuredInterviewResponse struct {
	ChatID            string                            `json:"chat_id"`
	Field             string                            `json:"field"`
	PreferredLanguage string                            `json:"preferred_language"`
	CurrentQuestion   int                               `json:"current_question"`
	TotalQuestions    int                               `json:"total_questions"`
	IsCompleted       bool                              `json:"is_completed"`
	NextQuestion      string                            `json:"next_question"`
	Message           string                            `json:"message"`
	SessionData       *StructuredInterviewSessionResponse `json:"session_data"`
}


// Conversion functions
func ToStructuredInterviewChatResponse(message *models.InterviewStructuredMessage) *StructuredInterviewChatResponse {
	return &StructuredInterviewChatResponse{
		ID:            message.ID,
		Role:          message.Role,
		Content:       message.Content,
		QuestionIndex: message.QuestionIndex,
		Timestamp:     message.Timestamp,
	}
}

func ToStructuredInterviewSessionResponse(chat *models.InterviewStructuredChat) *StructuredInterviewSessionResponse {
	var messages []StructuredInterviewChatResponse
	for _, msg := range chat.Messages {
		messages = append(messages, *ToStructuredInterviewChatResponse(&msg))
	}

	return &StructuredInterviewSessionResponse{
		ChatID:            chat.ID,
		UserID:            chat.UserID,
		Field:             chat.Field,
		PreferredLanguage: chat.PreferredLanguage,
		UserProfile:       chat.UserProfile,
		Questions:         chat.Questions,
		Messages:          messages,
		CurrentQuestion:   chat.CurrentQuestion,
		IsCompleted:       chat.IsCompleted,
		CreatedAt:         chat.CreatedAt,
		UpdatedAt:         chat.UpdatedAt,
	}
}

func ToStructuredInterviewChatSummary(chat *models.InterviewStructuredChat) StructuredInterviewChatSummary {
	lastMessage := ""
	if len(chat.Messages) > 0 {
		lastMessage = chat.Messages[len(chat.Messages)-1].Content
		if len(lastMessage) > 100 {
			lastMessage = lastMessage[:100] + "..."
		}
	}

	return StructuredInterviewChatSummary{
		ChatID:          chat.ID,
		Field:           chat.Field,
		UserProfile:     chat.UserProfile,
		CurrentQuestion: chat.CurrentQuestion,
		TotalQuestions:  len(chat.Questions),
		IsCompleted:     chat.IsCompleted,
		LastMessage:     lastMessage,
		CreatedAt:       chat.CreatedAt,
		UpdatedAt:       chat.UpdatedAt,
	}
}
