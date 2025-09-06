package dto

import "github.com/tsigemariamzewdu/JobMate-backend/domain/models"

type JobChatRequest struct {
	Message string `json:"message"`
	ChatID  string `json:"chat_id,omitempty"`
}

type JobChatResponse struct {
	Message string   `json:"message"`
	Jobs    []JobDTO `json:"jobs,omitempty"`
	ChatID  string   `json:"chat_id,omitempty"`
	Action  string   `json:"action,omitempty"`
}

func SimpleGroqAIMessageDTOToModel(dto GroqAIMessageDTO) *models.GroqAIMessage {
	return &models.GroqAIMessage{
		Role:    dto.Role,
		Content: dto.Content,
	}
}

func CreateSimpleGroqMessage(role, content string) GroqAIMessageDTO {
	return GroqAIMessageDTO{
		Role:    role,
		Content: content,
	}
}