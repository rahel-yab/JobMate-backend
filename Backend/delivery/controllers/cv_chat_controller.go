package controllers

import (
	"context"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	dto "github.com/tsigemariamzewdu/JobMate-backend/delivery/dto"
	usecaseInterfaces "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/usecases"
)

type CVChatController struct {
	CVChatUsecase usecaseInterfaces.ICVChatUsecase
}

func NewCVChatController(cvChatUsecase usecaseInterfaces.ICVChatUsecase) *CVChatController {
	return &CVChatController{
		CVChatUsecase: cvChatUsecase,
	}
}

func (c *CVChatController) SendMessage(gCtx *gin.Context) {
	var request dto.CVChatRequest

	if err := gCtx.ShouldBindJSON(&request); err != nil {
		gCtx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Extract user ID from authenticated context
	userID, exists := gCtx.Get("userID")
	if !exists {
		gCtx.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found in context"})
		return
	}

	ctx, cancel := context.WithTimeout(gCtx.Request.Context(), 30*time.Second)
	defer cancel()

	message, err := c.CVChatUsecase.SendMessage(ctx, userID.(string), request.Message, request.CVID)
	if err != nil {
		gCtx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	gCtx.JSON(http.StatusOK, dto.ToCVChatResponse(message))
}

func (c *CVChatController) CreateSession(gCtx *gin.Context) {
	var request dto.CVChatSessionRequest

	if err := gCtx.ShouldBindJSON(&request); err != nil {
		gCtx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Extract user ID from authenticated context
	userID, exists := gCtx.Get("userID")
	if !exists {
		gCtx.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found in context"})
		return
	}

	ctx, cancel := context.WithTimeout(gCtx.Request.Context(), 10*time.Second)
	defer cancel()

	chatID, err := c.CVChatUsecase.CreateCVChatSession(ctx, userID.(string), request.CVID)
	if err != nil {
		gCtx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	gCtx.JSON(http.StatusCreated, gin.H{"chat_id": chatID})
}

func (c *CVChatController) GetChatHistory(gCtx *gin.Context) {
	chatID := gCtx.Param("chat_id")
	if chatID == "" {
		gCtx.JSON(http.StatusBadRequest, gin.H{"error": "chat_id is required"})
		return
	}

	// Parse limit and offset query parameters
	limit := 20 // default limit
	offset := 0 // default offset
	
	if limitStr := gCtx.Query("limit"); limitStr != "" {
		if parsedLimit, err := strconv.Atoi(limitStr); err == nil && parsedLimit > 0 && parsedLimit <= 100 {
			limit = parsedLimit
		}
	}
	
	if offsetStr := gCtx.Query("offset"); offsetStr != "" {
		if parsedOffset, err := strconv.Atoi(offsetStr); err == nil && parsedOffset >= 0 {
			offset = parsedOffset
		}
	}

	ctx, cancel := context.WithTimeout(gCtx.Request.Context(), 10*time.Second)
	defer cancel()

	chat, err := c.CVChatUsecase.GetChatHistoryWithLimit(ctx, chatID, limit, offset)
	if err != nil {
		gCtx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	gCtx.JSON(http.StatusOK, dto.ToCVChatSessionResponse(chat))
}

func (c *CVChatController) GetUserChats(gCtx *gin.Context) {
	// Extract user ID from authenticated context
	userID, exists := gCtx.Get("userID")
	if !exists {
		gCtx.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found in context"})
		return
	}

	ctx, cancel := context.WithTimeout(gCtx.Request.Context(), 10*time.Second)
	defer cancel()

	chats, err := c.CVChatUsecase.GetUserCVChats(ctx, userID.(string))
	if err != nil {
		gCtx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	var responses []*dto.CVChatSessionResponse
	for _, chat := range chats {
		responses = append(responses, dto.ToCVChatSessionResponse(chat))
	}

	gCtx.JSON(http.StatusOK, responses)
}
