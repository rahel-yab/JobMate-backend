package ai

import (
	"context"

	"github.com/tsigemariamzewdu/JobMate-backend/delivery/dto"
	interfaces "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/services"
)

type GroqServiceAdapter struct {
	groqClient *GroqClient
}

func NewGroqServiceAdapter(groqClient *GroqClient) interfaces.IAIService {
	return &GroqServiceAdapter{
		groqClient: groqClient,
	}
}

// GetChatCompletion implements IAIService interface
func (g *GroqServiceAdapter) GetChatCompletion(ctx context.Context, messages []interfaces.AIMessage, tools []interfaces.AITool) (*interfaces.AIResponse, error) {
	// Convert domain messages to DTOs
	groqMessages := make([]dto.GroqAIMessageDTO, len(messages))
	for i, msg := range messages {
		groqMessages[i] = dto.GroqAIMessageDTO{
			Role:    msg.Role,
			Content: msg.Content,
		}
	}

	response, err := g.groqClient.GetChatCompletion(ctx, groqMessages)
	if err != nil {
		return nil, err
	}

	// Convert Groq response to domain response
	return &interfaces.AIResponse{
		Content: response.Content,
	}, nil
}

func (g *GroqServiceAdapter) GetCompletion(ctx context.Context, prompt string) (*interfaces.AIResponse, error) {
	messages := []dto.GroqAIMessageDTO{
		{Role: "user", Content: prompt},
	}

	response, err := g.groqClient.GetChatCompletion(ctx, messages)
	if err != nil {
		return nil, err
	}

	return &interfaces.AIResponse{
		Content: response.Content,
	}, nil
}