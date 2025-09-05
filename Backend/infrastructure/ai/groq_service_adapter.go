package ai

import (
	"context"
	"encoding/json"
	"fmt"

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
			Role:       msg.Role,
			Content:    msg.Content,
			ToolCallID: msg.ToolCallID,
		}
	}

	// Convert domain tools to DTOs
	groqTools := make([]dto.GroqToolDTO, len(tools))
	for i, tool := range tools {
		groqTools[i] = dto.GroqToolDTO{
			Type: tool.Type,
			Function: dto.GroqToolFunctionDTO{
				Name:        tool.Function.Name,
				Description: tool.Function.Description,
				Parameters: dto.GroqToolFunctionParametersDTO{
					Type:       tool.Function.Parameters.Type,
					Properties: convertProperties(tool.Function.Parameters.Properties),
					Required:   tool.Function.Parameters.Required,
				},
			},
		}
	}

	// Call Groq client
	response, err := g.groqClient.GetChatCompletion(ctx, groqMessages, groqTools)
	if err != nil {
		return nil, err
	}

	// Convert Groq response to domain response
	var domainToolCalls []interfaces.ToolCall
	if response.ToolCalls != nil {
		domainToolCalls = make([]interfaces.ToolCall, len(response.ToolCalls))
		for i, tc := range response.ToolCalls {
			// Convert arguments to string if needed
			var argsStr string
			if argBytes, ok := tc.Function.Arguments.([]byte); ok {
				argsStr = string(argBytes)
			} else if argStr, ok := tc.Function.Arguments.(string); ok {
				argsStr = argStr
			} else {
				argBytes, err := json.Marshal(tc.Function.Arguments)
				if err != nil {
					return nil, fmt.Errorf("failed to marshal tool arguments: %w", err)
				}
				argsStr = string(argBytes)
			}

			domainToolCalls[i] = interfaces.ToolCall{
				ID:   tc.ID,
				Type: "function",
				Function: interfaces.ToolCallFunction{
					Name:      tc.Function.Name,
					Arguments: argsStr,
				},
			}
		}
	}

	return &interfaces.AIResponse{
		Content:   response.Content,
		ToolCalls: domainToolCalls,
	}, nil
}


func (g *GroqServiceAdapter) GetCompletion(ctx context.Context, prompt string) (*interfaces.AIResponse, error) {
	messages := []dto.GroqAIMessageDTO{
		{Role: "user", Content: prompt},
	}

	response, err := g.groqClient.GetChatCompletion(ctx, messages, nil)
	if err != nil {
		return nil, err
	}

	return &interfaces.AIResponse{
		Content: response.Content,
	}, nil
}


func convertProperties(domainProps map[string]interfaces.AIToolProperty) map[string]dto.GroqToolPropertyDTO {
	groqProps := make(map[string]dto.GroqToolPropertyDTO)
	for key, prop := range domainProps {
		groqProps[key] = dto.GroqToolPropertyDTO{
			Type:        prop.Type,
			Description: prop.Description,
		}
	}
	return groqProps
}
