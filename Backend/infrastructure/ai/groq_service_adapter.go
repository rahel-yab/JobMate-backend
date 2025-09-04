package ai

import (
	"context"
	"encoding/json"

	"github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/services"
)

type GroqServiceAdapter struct {
	groqClient *GroqClient
}

func NewGroqServiceAdapter(groqClient *GroqClient) interfaces.IAIService {
	return &GroqServiceAdapter{
		groqClient: groqClient,
	}
}

func (g *GroqServiceAdapter) GetChatCompletion(ctx context.Context, messages []interfaces.AIMessage, tools []interfaces.AITool) (*interfaces.AIResponse, error) {
	groqMessages := make([]AIMessage, len(messages))
	for i, msg := range messages {
		groqMessages[i] = AIMessage{
			Role:       msg.Role,
			Content:    msg.Content,
			ToolCallID: msg.ToolCallID,
		}
	}

	groqTools := make([]GroqTool, len(tools))
	for i, tool := range tools {
		groqTools[i] = GroqTool{
			Type: tool.Type,
			Function: GroqToolFunction{
				Name:        tool.Function.Name,
				Description: tool.Function.Description,
				Parameters: GroqToolFunctionParameters{
					Type:       tool.Function.Parameters.Type,
					Properties: convertProperties(tool.Function.Parameters.Properties),
					Required:   tool.Function.Parameters.Required,
				},
			},
		}
	}

	response, err := g.groqClient.GetChatCompletion(ctx, groqMessages, groqTools)
	if err != nil {
		return nil, err
	}

	domainToolCalls := make([]interfaces.ToolCall, len(response.ToolCalls))
	for i, tc := range response.ToolCalls {
		var argsStr string
		if argBytes, ok := tc.Function.Arguments.([]byte); ok {
			argsStr = string(argBytes)
		} else if argStr, ok := tc.Function.Arguments.(string); ok {
			argsStr = argStr
		} else {
			argBytes, _ := json.Marshal(tc.Function.Arguments)
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

	return &interfaces.AIResponse{
		Content:   response.Content,
		ToolCalls: domainToolCalls,
	}, nil
}

func (g *GroqServiceAdapter) GetCompletion(ctx context.Context, prompt string) (*interfaces.AIResponse, error) {
	messages := []AIMessage{
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

func convertProperties(domainProps map[string]interfaces.AIToolProperty) map[string]GroqToolProperty {
	groqProps := make(map[string]GroqToolProperty)
	for key, prop := range domainProps {
		groqProps[key] = GroqToolProperty{
			Type:        prop.Type,
			Description: prop.Description,
		}
	}
	return groqProps
}