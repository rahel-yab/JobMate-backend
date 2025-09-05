package ai

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"

	svc "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/services"
	config "github.com/tsigemariamzewdu/JobMate-backend/infrastructure/config"
)

// --- Gemini Tooling Structs ---

type GeminiTool struct {
	FunctionDeclarations []GeminiFunctionDeclaration `json:"functionDeclarations"`
}

type GeminiFunctionDeclaration struct {
	Name        string           `json:"name"`
	Description string           `json:"description"`
	Parameters  GeminiParameters `json:"parameters"`
}

type GeminiParameters struct {
	Type       string                    `json:"type"`
	Properties map[string]GeminiProperty `json:"properties"`
	Required   []string                  `json:"required,omitempty"`
}

type GeminiProperty struct {
	Type        string          `json:"type"`
	Description string          `json:"description,omitempty"`
	Items       *GeminiProperty `json:"items,omitempty"`
}

// --- Response/Message Structs ---

type GeminiPart struct {
	Text         string               `json:"text,omitempty"`
	FunctionCall *GeminiFunctionCall  `json:"functionCall,omitempty"`
}

type GeminiContent struct {
	Role  string       `json:"role"`
	Parts []GeminiPart `json:"parts"`
}

type GeminiFunctionCall struct {
	Name string                 `json:"name"`
	Args map[string]interface{} `json:"args"`
}

// GeminiAPIResponse represents the response from Gemini
type GeminiAPIResponse struct {
	Candidates []struct {
		Content      GeminiContent `json:"content"`
		FinishReason string        `json:"finishReason"`
	} `json:"candidates"`
	Error struct {
		Message string `json:"message"`
	} `json:"error"`
	ModelVersion string `json:"modelVersion"`
}

type GeminiService struct {
	APIKey      string
	Model       string
	BaseURL     string
	Temperature float32
	HTTPClient  *http.Client
}

func NewGeminiService(cfg *config.Config) svc.IAIService {
	return &GeminiService{
		APIKey:      cfg.AIApiKey,
		Model:       cfg.AIModelName,
		BaseURL:     cfg.AIApiBaseUrl,
		Temperature: cfg.AITemperature,
		HTTPClient:  &http.Client{Timeout: 30 * time.Second},
	}
}

// --- Implement the IAIService interface ---
func (gs *GeminiService) GetChatCompletion(ctx context.Context, messages []svc.AIMessage, tools []svc.AITool) (*svc.AIResponse, error) {
	// Convert domain messages to Gemini format
	var contents []GeminiContent
	for _, msg := range messages {
		// Skip tool messages as Gemini doesn't support them in the same way
		if msg.Role == "tool" {
			continue
		}
		
		part := GeminiPart{Text: msg.Content}
		contents = append(contents, GeminiContent{
			Role:  convertRoleToGemini(msg.Role),
			Parts: []GeminiPart{part},
		})
	}

	// Convert tools to Gemini format if provided
	var geminiTools []GeminiTool
	if len(tools) > 0 {
		geminiTools = gs.convertToolsToGeminiFormat(tools)
	}

	// Build request body
	requestBody := map[string]interface{}{
		"contents": contents,
		"generationConfig": map[string]interface{}{
			"temperature": gs.Temperature,
		},
	}

	// Add tools if available
	if len(geminiTools) > 0 {
		requestBody["tools"] = geminiTools
	}

	jsonBody, err := json.Marshal(requestBody)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal Gemini API request: %w", err)
	}

	url := fmt.Sprintf("%s/v1beta/models/%s:generateContent?key=%s", gs.BaseURL, gs.Model, gs.APIKey)
	req, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewBuffer(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("failed to create Gemini API request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := gs.HTTPClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to send request to Gemini API: %w", err)
	}
	defer resp.Body.Close()

	// Debug: Print response status
	fmt.Printf("Gemini API Status: %s\n", resp.Status)

	if resp.StatusCode != http.StatusOK {
		// Try to read error response
		var errorResp map[string]interface{}
		if err := json.NewDecoder(resp.Body).Decode(&errorResp); err == nil {
			fmt.Printf("Gemini API Error: %+v\n", errorResp)
		}
		return nil, fmt.Errorf("gemini API returned status: %s", resp.Status)
	}

	var geminiResponse GeminiAPIResponse
	if err := json.NewDecoder(resp.Body).Decode(&geminiResponse); err != nil {
		return nil, fmt.Errorf("failed to decode Gemini API response: %w", err)
	}

	// Debug: Print raw response
	fmt.Printf("Gemini Response: %+v\n", geminiResponse)

	// Check for errors in response
	if geminiResponse.Error.Message != "" {
		return nil, fmt.Errorf("gemini API error: %s", geminiResponse.Error.Message)
	}

	// Process the response
	if len(geminiResponse.Candidates) == 0 {
		return nil, fmt.Errorf("gemini API returned no valid candidates")
	}

	candidate := geminiResponse.Candidates[0]
	aiResponse := &svc.AIResponse{}

	// Extract text content and tool calls
	for _, part := range candidate.Content.Parts {
		if part.Text != "" {
			aiResponse.Content += part.Text + "\n"
		}
		
		if part.FunctionCall != nil {
			// Convert Gemini function call to ToolCall
			argsJSON, err := json.Marshal(part.FunctionCall.Args)
			if err != nil {
				return nil, fmt.Errorf("failed to marshal function arguments: %w", err)
			}
			
			toolCall := svc.ToolCall{
				ID:   fmt.Sprintf("call_%s_%d", part.FunctionCall.Name, time.Now().UnixNano()),
				Type: "function",
				Function: svc.ToolCallFunction{
					Name:      part.FunctionCall.Name,
					Arguments: string(argsJSON),
				},
			}
			aiResponse.ToolCalls = append(aiResponse.ToolCalls, toolCall)
		}
	}

	// Clean up content
	if aiResponse.Content != "" {
		aiResponse.Content = strings.TrimSpace(aiResponse.Content)
	}

	return aiResponse, nil
}

func (gs *GeminiService) GetCompletion(ctx context.Context, prompt string) (*svc.AIResponse, error) {
	// For simple completion, create a user message and call GetChatCompletion
	messages := []svc.AIMessage{
		{
			Role:    "user",
			Content: prompt,
		},
	}
	
	return gs.GetChatCompletion(ctx, messages, nil)
}

// convertToolsToGeminiFormat converts IAIService tools to Gemini format
func (gs *GeminiService) convertToolsToGeminiFormat(tools []svc.AITool) []GeminiTool {
	var geminiTools []GeminiTool
	var functionDeclarations []GeminiFunctionDeclaration

	for _, tool := range tools {
		if tool.Type != "function" {
			continue // Skip non-function tools
		}

		// Convert parameters properties
		properties := make(map[string]GeminiProperty)
		for name, prop := range tool.Function.Parameters.Properties {
			geminiProp := GeminiProperty{
				Type:        prop.Type,
				Description: prop.Description,
			}
			// Handle array types
			if prop.Type == "array" {
				// You might need to handle this based on your specific schema
				geminiProp.Items = &GeminiProperty{Type: "string"}
			}
			properties[name] = geminiProp
		}

		functionDecl := GeminiFunctionDeclaration{
			Name:        tool.Function.Name,
			Description: tool.Function.Description,
			Parameters: GeminiParameters{
				Type:       tool.Function.Parameters.Type,
				Properties: properties,
				Required:   tool.Function.Parameters.Required,
			},
		}
		functionDeclarations = append(functionDeclarations, functionDecl)
	}

	if len(functionDeclarations) > 0 {
		geminiTools = append(geminiTools, GeminiTool{
			FunctionDeclarations: functionDeclarations,
		})
	}

	return geminiTools
}

// convertRoleToGemini converts standard roles to Gemini format
func convertRoleToGemini(role string) string {
	switch role {
	case "system":
		return "user" // Gemini doesn't have system role, convert to user
	case "assistant":
		return "model"
	default:
		return role
	}
}