package dto

import "github.com/tsigemariamzewdu/JobMate-backend/domain/models"


type GroqToolDTO struct {
	Type     string              `json:"type"`
	Function GroqToolFunctionDTO `json:"function"`
}


type GroqToolFunctionDTO struct {
	Name        string                         `json:"name"`
	Description string                         `json:"description"`
	Parameters  interface{} `json:"parameters"`
}


type GroqToolFunctionParametersDTO struct {
	Type       string                        `json:"type"`
	Properties map[string]GroqToolPropertyDTO `json:"properties"`
	Required   []string                      `json:"required,omitempty"`
}


type GroqToolPropertyDTO struct {
	Type        string               `json:"type"`
	Description string               `json:"description,omitempty"`
	Items       *GroqToolPropertyDTO `json:"items,omitempty"` // For array types
}


type ToolCallDTO struct {
	ID       string              `json:"id,omitempty"`
	Function ToolCallFunctionDTO `json:"function"`
}


type ToolCallFunctionDTO struct {
	Name      string      `json:"name"`
	Arguments interface{} `json:"arguments"`
}


type GroqAIMessageDTO struct {
	Role       string        `json:"role"`
	Content    string        `json:"content,omitempty"`
	ToolCalls  []ToolCallDTO `json:"tool_calls,omitempty"`
	ToolCallID string        `json:"tool_call_id,omitempty"`
}

// Conversion functions from models to DTOs
func ToGroqToolDTO(tool models.GroqTool) GroqToolDTO {
	return GroqToolDTO{
		Type:     tool.Type,
		Function: ToGroqToolFunctionDTO(tool.Function),
	}
}

func ToGroqToolFunctionDTO(function models.GroqToolFunction) GroqToolFunctionDTO {
	return GroqToolFunctionDTO{
		Name:        function.Name,
		Description: function.Description,
		Parameters:  ToGroqToolFunctionParametersDTO(function.Parameters),
	}
}

func ToGroqToolFunctionParametersDTO(params models.GroqToolFunctionParameters) GroqToolFunctionParametersDTO {
	properties := make(map[string]GroqToolPropertyDTO)
	for key, prop := range params.Properties {
		properties[key] = ToGroqToolPropertyDTO(prop)
	}
	
	return GroqToolFunctionParametersDTO{
		Type:       params.Type,
		Properties: properties,
		Required:   params.Required,
	}
}

func ToGroqToolPropertyDTO(prop models.GroqToolProperty) GroqToolPropertyDTO {
	dto := GroqToolPropertyDTO{
		Type:        prop.Type,
		Description: prop.Description,
	}
	
	if prop.Items != nil {
		itemsDTO := ToGroqToolPropertyDTO(*prop.Items)
		dto.Items = &itemsDTO
	}
	
	return dto
}

func ToToolCallDTO(toolCall models.ToolCall) ToolCallDTO {
	return ToolCallDTO{
		ID: toolCall.ID,
		Function: ToolCallFunctionDTO{
			Name:      toolCall.Function.Name,
			Arguments: toolCall.Function.Arguments,
		},
	}
}

func ToGroqAIMessageDTO(message models.GroqAIMessage) GroqAIMessageDTO {
	var toolCallDTOs []ToolCallDTO
	for _, tc := range message.ToolCalls {
		toolCallDTOs = append(toolCallDTOs, ToToolCallDTO(tc))
	}
	
	return GroqAIMessageDTO{
		Role:       message.Role,
		Content:    message.Content,
		ToolCalls:  toolCallDTOs,
		ToolCallID: message.ToolCallID,
	}
}

// GroqAIMessageDTOToModel converts DTO to domain GroqAIMessage pointer
func GroqAIMessageDTOToModel(dto GroqAIMessageDTO) *models.GroqAIMessage {
	var toolCalls []models.ToolCall
	for _, tcDTO := range dto.ToolCalls {
		toolCalls = append(toolCalls, models.ToolCall{
			ID: tcDTO.ID,
			Function: models.ToolCallFunction{
				Name:      tcDTO.Function.Name,
				Arguments: tcDTO.Function.Arguments,
			},
		})
	}
	
	return &models.GroqAIMessage{
		Role:       dto.Role,
		Content:    dto.Content,
		ToolCalls:  toolCalls,
		ToolCallID: dto.ToolCallID,
	}
}

// Conversion functions from DTOs to models
func FromGroqAIMessageDTO(dto GroqAIMessageDTO) models.GroqAIMessage {
	var toolCalls []models.ToolCall
	for _, tcDTO := range dto.ToolCalls {
		toolCalls = append(toolCalls, models.ToolCall{
			ID: tcDTO.ID,
			Function: models.ToolCallFunction{
				Name:      tcDTO.Function.Name,
				Arguments: tcDTO.Function.Arguments,
			},
		})
	}
	
	return models.GroqAIMessage{
		Role:       dto.Role,
		Content:    dto.Content,
		ToolCalls:  toolCalls,
		ToolCallID: dto.ToolCallID,
	}
}
