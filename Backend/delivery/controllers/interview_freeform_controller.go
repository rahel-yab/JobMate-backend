package controllers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/tsigemariamzewdu/JobMate-backend/delivery/dto"
	"github.com/tsigemariamzewdu/JobMate-backend/delivery/utils"
	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
	usecaseInterfaces "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/usecases"
)

type InterviewFreeformController struct {
	InterviewFreeformUsecase usecaseInterfaces.IInterviewFreeformUsecase
}

func NewInterviewFreeformController(interviewFreeformUsecase usecaseInterfaces.IInterviewFreeformUsecase) *InterviewFreeformController {
	return &InterviewFreeformController{
		InterviewFreeformUsecase: interviewFreeformUsecase,
	}
}

// CreateSession creates a new free-form interview chat session
func (ctrl *InterviewFreeformController) CreateSession(c *gin.Context) {
	var req dto.CreateInterviewSessionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request format", err.Error())
		return
	}

	userID, exists := c.Get("userID")
	if !exists {
		utils.ErrorResponse(c, http.StatusUnauthorized, "User not authenticated", "")
		return
	}

	chatID, err := ctrl.InterviewFreeformUsecase.CreateInterviewSession(c.Request.Context(), userID.(string), req.SessionType)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "Failed to create interview session", err.Error())
		return
	}

	response := dto.CreateInterviewSessionResponse{
		ChatID:      chatID,
		UserID:      userID.(string),
		SessionType: req.SessionType,
		Message:     "Free-form interview chat session created successfully. You can now ask questions and practice with the AI interview coach.",
		CreatedAt:   time.Now(),
	}

	utils.SuccessResponse(c, "Interview session created successfully", response)
}

// SendMessage sends a message in free-form interview chat
func (ctrl *InterviewFreeformController) SendMessage(c *gin.Context) {
	var req dto.SendInterviewMessageRequest
	ChatID:=c.Param("chat_id")
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ErrorResponse(c, http.StatusBadRequest, "Invalid request format", err.Error())
		return
	}

	userID, exists := c.Get("userID")
	if !exists {
		utils.ErrorResponse(c, http.StatusUnauthorized, "User not authenticated", "")
		return
	}

	aiResponse, err := ctrl.InterviewFreeformUsecase.SendMessage(c.Request.Context(), userID.(string), req.Message, ChatID)
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "Failed to process message", err.Error())
		return
	}

	response := dto.SendInterviewMessageResponse{
		ID:        aiResponse.ID,
		Role:      aiResponse.Role,
		Content:   aiResponse.Content,
		Timestamp: aiResponse.Timestamp,
	}

	utils.SuccessResponse(c, "Message processed successfully", response)
}

// GetChatHistory retrieves chat history for free-form interview
func (ctrl *InterviewFreeformController) GetChatHistory(c *gin.Context) {
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

	var chat *models.InterviewFreeformChat
	if limit > 0 {
		chat, err = ctrl.InterviewFreeformUsecase.GetChatHistoryWithLimit(c.Request.Context(), chatID, limit, offset)
	} else {
		chat, err = ctrl.InterviewFreeformUsecase.GetChatHistory(c.Request.Context(), chatID)
	}

	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "Failed to retrieve chat history", err.Error())
		return
	}

	response := dto.ToInterviewChatHistoryResponse(chat)
	utils.SuccessResponse(c, "Chat history retrieved successfully", response)
}

// GetUserChats retrieves all interview chat sessions for a user
func (ctrl *InterviewFreeformController) GetUserChats(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		utils.ErrorResponse(c, http.StatusUnauthorized, "User not authenticated", "")
		return
	}

	chats, err := ctrl.InterviewFreeformUsecase.GetUserInterviewChats(c.Request.Context(), userID.(string))
	if err != nil {
		utils.ErrorResponse(c, http.StatusInternalServerError, "Failed to retrieve user chats", err.Error())
		return
	}

	chatSummaries := make([]dto.InterviewChatSummary, 0, len(chats))
	for _, chat := range chats {
		chatSummaries = append(chatSummaries, dto.ToInterviewChatSummary(chat))
	}

	response := dto.UserInterviewChatsResponse{
		Chats: chatSummaries,
		Total: len(chatSummaries),
	}

	utils.SuccessResponse(c, "User chats retrieved successfully", response)
}
