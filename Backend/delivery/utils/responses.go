package utils

import (
	"github.com/gin-gonic/gin"
	"net/http"
)

func SuccessResponse(c *gin.Context, message string, data any) {
	c.JSON(http.StatusOK, SuccessPayload(message, data))
}

func ErrorResponse(c *gin.Context, statusCode int, message string, details any) {
	c.JSON(statusCode, ErrorPayload(message, details))
}

func SuccessPayload(message string, data any) gin.H {
	return gin.H{
		"success": true,
		"message": message,
		"data":    data,
	}
}

func ErrorPayload(message string, details any) gin.H {
	return gin.H{
		"success": false,
		"message": message,
		"details": details,
	}
}