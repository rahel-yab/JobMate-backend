package ai

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
	
	"net/http"
	"time"

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
	Type        string         `json:"type"`
	Description string         `json:"description,omitempty"`
	Items       *GeminiProperty `json:"items,omitempty"`
}

// --- Response/Message Structs ---

type GeminiPart struct {
	Text             string               `json:"text,omitempty"`
	FunctionResponse *GeminiFunctionResponse `json:"functionResponse,omitempty"`
	FunctionCall     *GeminiFunctionCall    `json:"functionCall,omitempty"`
}

type GeminiContent struct {
	Role  string        `json:"role"`
	Parts []GeminiPart `json:"parts"`
}

type GeminiFunctionCall struct {
	Name string                 `json:"name"`
	Args map[string]interface{} `json:"args"`
}

type GeminiFunctionResponse struct {
	Name     string                 `json:"name"`
	Response map[string]interface{} `json:"response"`
}

type GeminiMessage struct {
	Role  string       `json:"role"`
	Parts []GeminiPart `json:"parts"`
}

// GeminiAPIResponse represents the response from Gemini
type GeminiAPIResponse struct {
	Candidates []struct {
		Content      GeminiContent `json:"content"`
		FinishReason string        `json:"finishReason"`
	} `json:"candidates"`
	ModelVersion string `json:"modelVersion"`
}

type GeminiClient struct {
	APIKey      string
	Model       string
	BaseURL     string
	Temperature float32
	HTTPClient  *http.Client
}

func NewGeminiClient(cfg *config.Config) *GeminiClient {
	return &GeminiClient{
		APIKey:      cfg.AIApiKey,
		Model:       cfg.AIModelName,
		BaseURL:     cfg.AIApiBaseUrl,
		Temperature: cfg.AITemperature,
		HTTPClient:  &http.Client{Timeout: 30 * time.Second},
	}
}

// --- Implement the IAIClient interface ---
func (gc *GeminiClient) GetChatCompletion(ctx context.Context, messages []models.AIMessage) (string, error) {
	// convert domain models -> Gemini request
	var contents []GeminiContent
	for _, msg := range messages {
		contents = append(contents, GeminiContent{
			Role: msg.Role,
			Parts: []GeminiPart{
				{Text: msg.Content},
			},
		})
	}

	requestBody := map[string]interface{}{
		"contents": contents,
		"generationConfig": map[string]interface{}{
			"temperature": gc.Temperature,
		},
	}

	jsonBody, err := json.Marshal(requestBody)
	if err != nil {
		return "", fmt.Errorf("failed to marshal Gemini API request: %w", err)
	}

	url := fmt.Sprintf("%s/v1beta/models/%s:generateContent?key=%s", gc.BaseURL, gc.Model, gc.APIKey)
	req, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewBuffer(jsonBody))
	if err != nil {
		return "", fmt.Errorf("failed to create Gemini API request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := gc.HTTPClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to send request to Gemini API: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("gemini API returned status: %s", resp.Status)
	}

	var geminiResponse GeminiAPIResponse
	if err := json.NewDecoder(resp.Body).Decode(&geminiResponse); err != nil {
		return "", fmt.Errorf("failed to decode Gemini API response: %w", err)
	}

	if len(geminiResponse.Candidates) > 0 && len(geminiResponse.Candidates[0].Content.Parts) > 0 {
		return geminiResponse.Candidates[0].Content.Parts[0].Text, nil
	}

	return "", fmt.Errorf("gemini API returned no valid candidates")
}
