package usecases

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"github.com/tsigemariamzewdu/JobMate-backend/delivery/dto"
	repositories "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/repositories"
	services "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/services"
	usecaseInterfaces "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/usecases"
	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
)

type InterviewStructuredUsecase struct {
	InterviewStructuredRepository repositories.IInterviewStructuredRepository
	AuthRepository                repositories.IAuthRepository
	AIService                     services.IAIService
}

func NewInterviewStructuredUsecase(
	interviewStructuredRepo repositories.IInterviewStructuredRepository,
	authRepo repositories.IAuthRepository,
	aiService services.IAIService,
) usecaseInterfaces.IInterviewStructuredUsecase {
	return &InterviewStructuredUsecase{
		InterviewStructuredRepository: interviewStructuredRepo,
		AuthRepository:                authRepo,
		AIService:                     aiService,
	}
}

func (u *InterviewStructuredUsecase) GenerateInterviewQuestions(ctx context.Context, field string, userProfile map[string]interface{}) ([]string, error) {
	profileStr := u.formatUserProfile(userProfile)

	systemPrompt := `You are JobMate's Expert Interview Coach for Ethiopian job seekers. Your role is to generate realistic, field-specific interview questions that help students practice for actual job interviews.

CONTEXT: The interview has started. You will generate exactly 6 progressive questions for practice.

GUIDELINES:
- Generate questions commonly asked in Ethiopian job market
- Mix behavioral (STAR method), technical, and situational questions  
- Progress from basic to advanced difficulty
- Consider user's experience level and background
- Questions should be realistic and industry-relevant
- Return ONLY a JSON array of 6 questions`

	userPrompt := fmt.Sprintf(`INTERVIEW SETUP:
Field: %s
User Profile: %s

Generate exactly 6 interview questions for this candidate. The questions should:
1. Start with introductory/background questions
2. Include 2-3 behavioral questions (suitable for STAR method)
3. Include 2-3 technical/field-specific questions
4. End with career/future-oriented questions

Return format: ["Question 1", "Question 2", "Question 3", "Question 4", "Question 5", "Question 6"]`, field, profileStr)

	aiMessages := []services.AIMessage{
		{Role: "system", Content: systemPrompt},
		{Role: "user", Content: userPrompt},
	}

	response, err := u.AIService.GetChatCompletion(ctx, aiMessages, nil)
	if err != nil {
		return u.getFallbackQuestions(field), nil
	}

	questions, err := u.parseQuestionsFromAI(response.Content)
	if err != nil || len(questions) != 6 {
		return u.getFallbackQuestions(field), nil
	}

	return questions, nil
}

func (u *InterviewStructuredUsecase) StartStructuredInterview(ctx context.Context, userID, field string) (chatID, firstQuestion string, totalQuestions int, err error) {
	// Fetch user profile from database
	user, err := u.AuthRepository.FindByID(ctx, userID)
	if err != nil {
		return "", "", 0, fmt.Errorf("failed to get user profile: %w", err)
	}

	// Convert user model to profile map for AI
	userProfile := u.buildUserProfileFromModel(user)

	// Generate interview questions using AI
	questions, err := u.GenerateInterviewQuestions(ctx, field, userProfile)
	if err != nil {
		return "", "", 0, fmt.Errorf("failed to generate questions: %w", err)
	}

	// Start the interview session
	chatID, err = u.InterviewStructuredRepository.StartInterview(ctx, userID, field, userProfile, questions)
	if err != nil {
		return "", "", 0, err
	}

	profileStr := u.formatUserProfile(userProfile)
	initialPrompt := fmt.Sprintf(`INTERVIEW SESSION STARTED

Field: %s
Candidate Profile: %s
Total Questions: %d

I am your interview coach and will guide you through %d practice questions. After each answer, I'll provide feedback to help you improve. 

Let's begin with the first question:

%s`, field, profileStr, len(questions), len(questions), questions[0])

	initialMsg := models.InterviewStructuredMessage{
		Role:          "assistant",
		Content:       initialPrompt,
		QuestionIndex: 0,
		Timestamp:     time.Now(),
	}

	err = u.InterviewStructuredRepository.AppendMessage(ctx, chatID, initialMsg)
	if err != nil {
		return "", "", 0, fmt.Errorf("failed to save initial message: %w", err)
	}

	return chatID, questions[0], len(questions), nil
}

func (u *InterviewStructuredUsecase) ProcessAnswer(ctx context.Context, userID, chatID, answer string) (*dto.InterviewAnswerResponse, error) {
	chat, err := u.InterviewStructuredRepository.GetInterviewChatByID(ctx, chatID)
	if err != nil {
		return nil, fmt.Errorf("failed to get interview session: %w", err)
	}

	if chat.UserID != userID {
		return nil, fmt.Errorf("unauthorized access to interview")
	}

	if chat.IsCompleted {
		return nil, fmt.Errorf("interview session is already completed")
	}

	userMessage := models.InterviewStructuredMessage{
		Role:          "user",
		Content:       answer,
		QuestionIndex: chat.CurrentQuestion,
		Timestamp:     time.Now(),
	}

	err = u.InterviewStructuredRepository.AppendMessage(ctx, chatID, userMessage)
	if err != nil {
		return nil, fmt.Errorf("failed to save user answer: %w", err)
	}

	currentQuestion := ""
	if chat.CurrentQuestion < len(chat.Questions) {
		currentQuestion = chat.Questions[chat.CurrentQuestion]
	}

	feedback, err := u.generateAnswerFeedback(ctx, answer, currentQuestion, chat.Field, chat.UserProfile)
	if err != nil {
		feedback = "Thank you for your answer. Let's continue to the next question."
	}

	nextQuestionIndex := chat.CurrentQuestion + 1
	isLastQuestion := nextQuestionIndex >= len(chat.Questions)

	var responseContent string
	if isLastQuestion {
		responseContent = fmt.Sprintf(`%s

🎉 Congratulations! You have successfully completed your interview practice session.

Your Performance Summary:
- You answered all %d questions with dedication
- You should continue practicing the STAR method for behavioral questions
- You need to keep building your confidence through regular practice
- You can review the feedback provided for each answer to improve further

You did an excellent job completing this interview practice! Keep up the great work and continue preparing for your real interviews.`, feedback, len(chat.Questions))

		err = u.InterviewStructuredRepository.UpdateSessionState(ctx, chatID, nextQuestionIndex, true)
		if err != nil {
			return nil, fmt.Errorf("failed to complete interview: %w", err)
		}
	} else {
		nextQuestion := chat.Questions[nextQuestionIndex]
		responseContent = fmt.Sprintf(`%s

Next Question (%d/%d):
%s`, feedback, nextQuestionIndex+1, len(chat.Questions), nextQuestion)

		err = u.InterviewStructuredRepository.UpdateSessionState(ctx, chatID, nextQuestionIndex, false)
		if err != nil {
			return nil, fmt.Errorf("failed to update interview state: %w", err)
		}
	}

	aiMessage := models.InterviewStructuredMessage{
		Role:          "assistant",
		Content:       responseContent,
		QuestionIndex: nextQuestionIndex,
		Timestamp:     time.Now(),
	}

	err = u.InterviewStructuredRepository.AppendMessage(ctx, chatID, aiMessage)
	if err != nil {
		return nil, fmt.Errorf("failed to save AI feedback: %w", err)
	}

	nextQuestionText := ""
	if !isLastQuestion {
		nextQuestionText = chat.Questions[nextQuestionIndex]
	}

	return &dto.InterviewAnswerResponse{
		Feedback:       responseContent,
		NextQuestion:   nextQuestionText,
		QuestionIndex:  nextQuestionIndex,
		TotalQuestions: len(chat.Questions),
		IsCompleted:    isLastQuestion,
	}, nil
}

func (u *InterviewStructuredUsecase) formatUserProfile(userProfile map[string]interface{}) string {
	var parts []string

	if name, ok := userProfile["name"].(string); ok && name != "" {
		parts = append(parts, fmt.Sprintf("Name: %s", name))
	}
	if experience, ok := userProfile["experience"].(string); ok && experience != "" {
		parts = append(parts, fmt.Sprintf("Experience: %s", experience))
	}
	if education, ok := userProfile["education"].(string); ok && education != "" {
		parts = append(parts, fmt.Sprintf("Education: %s", education))
	}
	if skills, ok := userProfile["skills"].(string); ok && skills != "" {
		parts = append(parts, fmt.Sprintf("Skills: %s", skills))
	}

	if len(parts) == 0 {
		return "No profile information provided"
	}

	return strings.Join(parts, ", ")
}

func (u *InterviewStructuredUsecase) parseQuestionsFromAI(aiResponse string) ([]string, error) {
	aiResponse = strings.TrimSpace(aiResponse)

	start := strings.Index(aiResponse, "[")
	end := strings.LastIndex(aiResponse, "]")

	if start == -1 || end == -1 || start >= end {
		return nil, fmt.Errorf("no valid JSON array found in AI response")
	}

	jsonStr := aiResponse[start : end+1]

	var questions []string
	err := json.Unmarshal([]byte(jsonStr), &questions)
	if err != nil {
		return nil, fmt.Errorf("failed to parse questions JSON: %w", err)
	}

	return questions, nil
}

func (u *InterviewStructuredUsecase) getFallbackQuestions(field string) []string {
	baseQuestions := []string{
		"Tell me about yourself and your background.",
		"Why are you interested in this " + field + " position?",
		"Describe a challenging project you worked on. How did you handle it?",
		"What are your greatest strengths and how do they apply to this role?",
		"Where do you see yourself in 5 years?",
		"Do you have any questions for us about the company or role?",
	}

	return baseQuestions
}

func (u *InterviewStructuredUsecase) generateAnswerFeedback(ctx context.Context, answer, question, field string, userProfile map[string]interface{}) (string, error) {
	profileStr := u.formatUserProfile(userProfile)

	systemPrompt := `You are JobMate's Interview Coach providing feedback on candidate answers. Your role is to give constructive, specific feedback that helps Ethiopian job seekers improve their interview performance.

GUIDELINES:
- Provide specific, actionable feedback
- Be encouraging but honest
- Suggest improvements for structure, content, and delivery
- Reference STAR method for behavioral questions when appropriate
- Keep feedback concise but helpful
- Consider Ethiopian workplace culture
- Focus on practical improvements`

	userPrompt := fmt.Sprintf(`FEEDBACK REQUEST:
Field: %s
Candidate Profile: %s
Question Asked: %s
Candidate's Answer: %s

Please provide constructive feedback on this answer. Include:
1. What was done well
2. Areas for improvement
3. Specific suggestions for better responses
4. Any relevant interview techniques (like STAR method)

Keep feedback encouraging and practical.`, field, profileStr, question, answer)

	aiMessages := []services.AIMessage{
		{Role: "system", Content: systemPrompt},
		{Role: "user", Content: userPrompt},
	}

	response, err := u.AIService.GetChatCompletion(ctx, aiMessages, nil)
	if err != nil {
		return "Thank you for your answer. Practice using specific examples and the STAR method for behavioral questions.", nil
	}

	return strings.TrimSpace(response.Content), nil
}

func (u *InterviewStructuredUsecase) buildUserProfileFromModel(user *models.User) map[string]interface{} {
	profile := make(map[string]interface{})

	if user.FirstName != nil && *user.FirstName != "" {
		if user.LastName != nil && *user.LastName != "" {
			profile["name"] = *user.FirstName + " " + *user.LastName
		} else {
			profile["name"] = *user.FirstName
		}
	}

	if user.YearsExperience != nil {
		profile["experience_years"] = *user.YearsExperience
	}

	if user.EducationLevel != nil {
		profile["education"] = string(*user.EducationLevel)
	}

	if user.FieldOfStudy != nil && *user.FieldOfStudy != "" {
		profile["field_of_study"] = *user.FieldOfStudy
	}

	if user.CareerInterests != nil && *user.CareerInterests != "" {
		profile["skills"] = *user.CareerInterests
	}

	if user.CareerGoals != nil && *user.CareerGoals != "" {
		profile["career_goals"] = *user.CareerGoals
	}

	return profile
}

// Note: Placeholder methods removed as they don't belong in the structured usecase interface

func (u *InterviewStructuredUsecase) GetChatHistory(ctx context.Context, chatID string) (*models.InterviewStructuredChat, error) {
	return u.InterviewStructuredRepository.GetChatHistory(ctx, chatID)
}

func (u *InterviewStructuredUsecase) GetChatHistoryWithLimit(ctx context.Context, chatID string, limit, offset int) (*models.InterviewStructuredChat, error) {
	return u.InterviewStructuredRepository.GetChatHistoryWithLimit(ctx, chatID, limit, offset)
}

func (u *InterviewStructuredUsecase) GetUserInterviewChats(ctx context.Context, userID string) ([]*models.InterviewStructuredChat, error) {
	return u.InterviewStructuredRepository.GetUserInterviewChats(ctx, userID)
}

func (u *InterviewStructuredUsecase) GetNextQuestion(ctx context.Context, chatID string) (string, error) {
	chat, err := u.InterviewStructuredRepository.GetChatHistory(ctx, chatID)
	if err != nil {
		return "", err
	}
	if chat.CurrentQuestion < len(chat.Questions) {
		return chat.Questions[chat.CurrentQuestion], nil
	}
	return "", fmt.Errorf("no more questions available")
}

func (u *InterviewStructuredUsecase) CompleteSession(ctx context.Context, chatID string) error {
	chat, err := u.InterviewStructuredRepository.GetInterviewChatByID(ctx, chatID)
	if err != nil {
		return err
	}
	return u.InterviewStructuredRepository.UpdateSessionState(ctx, chatID, chat.CurrentQuestion, true)
}
