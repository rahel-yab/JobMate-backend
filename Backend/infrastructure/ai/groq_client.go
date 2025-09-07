package ai

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/tsigemariamzewdu/JobMate-backend/delivery/dto"
	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
	config "github.com/tsigemariamzewdu/JobMate-backend/infrastructure/config"
)

// GroqAPIResponse represents the response body from the Groq API (internal to ai package)
type GroqAPIResponse struct {
	Choices []struct {
		Message      dto.GroqAIMessageDTO `json:"message"`
		FinishReason string               `json:"finish_reason"`
		Index        int                  `json:"index"`
	} `json:"choices"`
	Created int    `json:"created"`
	ID      string `json:"id"`
	Model   string `json:"model"`
	Object  string `json:"object"`
	Usage   struct {
		CompletionTokens int `json:"completion_tokens"`
		PromptTokens     int `json:"prompt_tokens"`
		TotalTokens      int `json:"total_tokens"`
	} `json:"usage"`
}

type GroqClient struct {
	APIKey      string
	Model       string
	BaseURL     string
	Temperature float32
	HTTPClient  *http.Client
}

// var _ svc.IAIClient = (*GroqClient)(nil) // Will re-evaluate this after refactoring

// NewGroqClient creates a new GroqClient instance
func NewGroqClient(cfg *config.Config) *GroqClient {
	return &GroqClient{
		APIKey:      cfg.AIApiKey,
		Model:       cfg.AIModelName,
		BaseURL:     cfg.AIApiBaseUrl,
		Temperature: cfg.AITemperature,
		HTTPClient:  &http.Client{Timeout: 30 * time.Second},
	}
}

// GetChatCompletion sends a request to the Groq API and returns the AI's response
func (gc *GroqClient) GetChatCompletion(ctx context.Context, messages []dto.GroqAIMessageDTO, tools interface{}) (*models.GroqAIMessage, error) {

	requestBody := struct {
		Messages    []dto.GroqAIMessageDTO `json:"messages"`
		Model       string                 `json:"model"`
		Temperature float32                `json:"temperature"`
		MaxTokens   int                    `json:"max_tokens,omitempty"`
		Stream      bool                   `json:"stream,omitempty"`
		Tools       interface{}            `json:"tools,omitempty"`  // Changed to interface{}
	}{
		Messages:    messages,
		Model:       gc.Model,
		Temperature: gc.Temperature,
		MaxTokens:   1000,
		Stream:      false,
		Tools:       tools,
	}

	jsonBody, err := json.Marshal(requestBody)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal Groq API request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, "POST", fmt.Sprintf("%s/chat/completions", gc.BaseURL), bytes.NewBuffer(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("failed to create Groq API request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", gc.APIKey))

	resp, err := gc.HTTPClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to send request to Groq API: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		var errorResponse struct {
			Error struct {
				Message string `json:"message"`
				Type    string `json:"type"`
			} `json:"error"`
		}
		if decodeErr := json.NewDecoder(resp.Body).Decode(&errorResponse); decodeErr == nil {
			return nil, fmt.Errorf("groq API returned error status %d: %s (Type: %s)", resp.StatusCode, errorResponse.Error.Message, errorResponse.Error.Type)
		}
		return nil, fmt.Errorf("groq API returned error status: %s", resp.Status)
	}

	var groqResponse GroqAPIResponse
	if err := json.NewDecoder(resp.Body).Decode(&groqResponse); err != nil {
		return nil, fmt.Errorf("failed to decode Groq API response: %w", err)
	}

	if len(groqResponse.Choices) > 0 {
		// Convert DTO to domain model
		responseMessage := groqResponse.Choices[0].Message
		return dto.GroqAIMessageDTOToModel(responseMessage), nil
	}

	return nil, fmt.Errorf("groq API returned no choices")
}
