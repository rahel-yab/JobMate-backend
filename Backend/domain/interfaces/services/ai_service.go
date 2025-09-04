package interfaces

import (
	"context"
	"encoding/json"
)

// AIMessage represents a message in AI conversation
type AIMessage struct {
	Role       string `json:"role"`
	Content    string `json:"content"`
	ToolCallID string `json:"tool_call_id,omitempty"`
}

// ToolCall represents an AI tool function call
type ToolCall struct {
	ID       string           `json:"id"`
	Type     string           `json:"type"`
	Function ToolCallFunction `json:"function"`
}

// ToolCallFunction represents the function details in a tool call
type ToolCallFunction struct {
	Name      string `json:"name"`
	Arguments string `json:"arguments"`
}

// GetArgumentsAsMap parses the arguments JSON string into a map
func (tcf *ToolCallFunction) GetArgumentsAsMap() (map[string]interface{}, error) {
	var args map[string]interface{}
	err := json.Unmarshal([]byte(tcf.Arguments), &args)
	return args, err
}

// AITool represents a tool that AI can use
type AITool struct {
	Type     string         `json:"type"`
	Function AIToolFunction `json:"function"`
}

// AIToolFunction represents the function definition for AI tools
type AIToolFunction struct {
	Name        string                   `json:"name"`
	Description string                   `json:"description"`
	Parameters  AIToolFunctionParameters `json:"parameters"`
}

// AIToolFunctionParameters represents the parameters schema for AI tools
type AIToolFunctionParameters struct {
	Type       string                    `json:"type"`
	Properties map[string]AIToolProperty `json:"properties"`
	Required   []string                  `json:"required"`
}

// AIToolProperty represents a property in AI tool parameters
type AIToolProperty struct {
	Type        string `json:"type"`
	Description string `json:"description"`
}

// AIResponse represents the response from AI service
type AIResponse struct {
	Content   string     `json:"content"`
	ToolCalls []ToolCall `json:"tool_calls,omitempty"`
}

// IAIService defines the interface for AI operations
type IAIService interface {
	// GetChatCompletion generates AI response for chat messages
	GetChatCompletion(ctx context.Context, messages []AIMessage, tools []AITool) (*AIResponse, error)

	// GetCompletion generates AI response for a single prompt
	GetCompletion(ctx context.Context, prompt string) (*AIResponse, error)
}
