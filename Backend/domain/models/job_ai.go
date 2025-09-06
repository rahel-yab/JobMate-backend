package models

type JobAIResponse struct {
    Message string    `json:"message"`
    Jobs    []Job     `json:"jobs,omitempty"`
    ChatID  string    `json:"chat_id,omitempty"`
    Action  string    `json:"action,omitempty"` 
}

type GroqAIMessage2 struct {
    Content    string         `json:"content"`
    ToolCalls  []GroqToolCall `json:"tool_calls,omitempty"`
}

type GroqToolCall struct {
    ID       string          `json:"id"`
    Type     string          `json:"type"`
    Function GroqToolFunction `json:"function"`
}

type GroqToolFunction2 struct {
    Name      string      `json:"name"`
    Arguments interface{} `json:"arguments"`
}

type AIMessage2 struct {
    Role    string `json:"role"`
    Content string `json:"content"`
}