package models


type GroqTool struct {
	Type     string
	Function GroqToolFunction
}


type GroqToolFunction struct {
	Name        string
	Description string
	Parameters  GroqToolFunctionParameters
}


type GroqToolFunctionParameters struct {
	Type       string
	Properties map[string]GroqToolProperty
	Required   []string
}


type GroqToolProperty struct {
	Type        string
	Description string
	Items       *GroqToolProperty // For array types
}


type ToolCall struct {
	ID       string
	Function ToolCallFunction
}


type ToolCallFunction struct {
	Name      string
	Arguments interface{}
}

type GroqAIMessage struct {
	Role       string
	Content    string
	ToolCalls  []ToolCall
	ToolCallID string
}
