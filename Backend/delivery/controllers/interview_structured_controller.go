package controllers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/tsigemariamzewdu/JobMate-backend/delivery/dto"
	"github.com/tsigemariamzewdu/JobMate-backend/delivery/utils"
	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
	usecaseInterfaces "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/usecases"
)

type InterviewStructuredController struct {
	InterviewStructuredUsecase usecaseInterfaces.IInterviewStructuredUsecase
}

func NewInterviewStructuredController(interviewStructuredUsecase usecaseInterfaces.IInterviewStructuredUsecase) *InterviewStructuredController {
	return &InterviewStructuredController{
		InterviewStructuredUsecase: interviewStructuredUsecase,
	}
}

// StartInterview starts a structured interview with AI-generated questions
func (ctrl *InterviewStructuredController) StartInterview(c *gin.Context) {
	var req dto.StartStructuredInterviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request format", err.Error())
		return
	}

	userID, exists := c.Get("userID")
	if !exists {
		utils.ErrorResponse(c, http.StatusUnauthorized, "User not authenticated", "")
		return
	}
	chatID, firstQuestion, totalQuestions, err := ctrl.InterviewStructuredUsecase.StartStructuredInterview(c.Request.Context(), userID.(string), req.Field)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "Failed to start interview session", err.Error())
		return
	}

	response := dto.StartStructuredInterviewResponse{
		ChatID:         chatID,
		Field:          req.Field,
		TotalQuestions: totalQuestions,
		FirstQuestion:  firstQuestion,
		Message:        "Structured interview started successfully. Answer each question and receive feedback before proceeding to the next.",
	}

	utils.SuccessResponse(c, "Structured interview started successfully", response)
}

// SubmitAnswer processes user's answer and provides feedback + next question
func (ctrl *InterviewStructuredController) SubmitAnswer(c *gin.Context) {
	chatID := c.Param("chat_id")
	if chatID == "" {
		utils.ErrorResponse(c, http.StatusBadRequest, "Chat ID is required", "")
		return
	}

	var req dto.SubmitInterviewAnswerRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request format", err.Error())
		return
	}

	userID, exists := c.Get("userID")
	if !exists {
		utils.ErrorResponse(c, http.StatusUnauthorized, "User not authenticated", "")
		return
	}

	// Process the answer and get feedback
	response, err := ctrl.InterviewStructuredUsecase.ProcessAnswer(c.Request.Context(), userID.(string), chatID, req.Answer)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "Failed to process answer", err.Error())
		return
	}

	utils.SuccessResponse(c, "Answer processed successfully", response)
}

// GetChatHistory retrieves chat history for structured interview
func (ctrl *InterviewStructuredController) GetChatHistory(c *gin.Context) {
	chatID := c.Param("chat_id")
	if chatID == "" {
		utils.ErrorResponse(c, http.StatusBadRequest, "Chat ID is required", "")
		return
	}

	limitStr := c.DefaultQuery("limit", "50")
	offsetStr := c.DefaultQuery("offset", "0")

	limit, err := strconv.Atoi(limitStr)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid limit parameter", err.Error())
		return
	}

	offset, err := strconv.Atoi(offsetStr)
	if err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid offset parameter", err.Error())
		return
	}

	var chat *models.InterviewStructuredChat
	if limit > 0 {
		chat, err = ctrl.InterviewStructuredUsecase.GetChatHistoryWithLimit(c.Request.Context(), chatID, limit, offset)
	} else {
		chat, err = ctrl.InterviewStructuredUsecase.GetChatHistory(c.Request.Context(), chatID)
	}

	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "Failed to retrieve chat history", err.Error())
		return
	}

	
	response := dto.ToStructuredInterviewSessionResponse(chat)
	utils.SuccessResponse(c, "Chat history retrieved successfully", response)
}

// GetUserChats retrieves all structured interview chat sessions for a user
func (ctrl *InterviewStructuredController) GetUserChats(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		utils.ErrorResponse(c, http.StatusUnauthorized, "User not authenticated", "")
		return
	}

	chats, err := ctrl.InterviewStructuredUsecase.GetUserInterviewChats(c.Request.Context(), userID.(string))
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "Failed to retrieve user chats", err.Error())
		return
	}

	var chatSummaries []dto.StructuredInterviewChatSummary
	for _, chat := range chats {
		chatSummaries = append(chatSummaries, dto.ToStructuredInterviewChatSummary(chat))
	}

	response := dto.UserStructuredInterviewChatsResponse{
		Chats: chatSummaries,
		Total: len(chatSummaries),
	}

	utils.SuccessResponse(c, "User chats retrieved successfully", response)
}
