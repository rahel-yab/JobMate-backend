package dto

import "github.com/tsigemariamzewdu/JobMate-backend/domain/models"

// JobSearchCriteriaDTO represents the extracted job search criteria
type JobSearchCriteriaDTO struct {
	Experience string   `json:"experience"`
	Field      string   `json:"field"`
	Language   string   `json:"language"`
	LookingFor string   `json:"looking_for"`
	Skills     []string `json:"skills"`
}

// GroqAIMessageDTO represents the AI response
type GroqAIMessageDTO struct {
	Role    string `json:"role"`
	Content string `json:"content,omitempty"`
}

// Conversion functions
func ToGroqAIMessageDTO(message models.GroqAIMessage) GroqAIMessageDTO {
	return GroqAIMessageDTO{
		Role:    message.Role,
		Content: message.Content,
	}
}

func GroqAIMessageDTOToModel(dto GroqAIMessageDTO) *models.GroqAIMessage {
	return &models.GroqAIMessage{
		Role:    dto.Role,
		Content: dto.Content,
	}
}