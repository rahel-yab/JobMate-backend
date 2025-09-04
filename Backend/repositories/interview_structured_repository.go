package repositories

import (
	"context"
	"fmt"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"

	repositories "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/repositories"
	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
)

type InterviewStructuredRepository struct {
	collection *mongo.Collection
}

func NewInterviewStructuredRepository(db *mongo.Database) repositories.IInterviewStructuredRepository {
	return &InterviewStructuredRepository{
		collection: db.Collection("interview_structured_chats"),
	}
}

func (r *InterviewStructuredRepository) StartInterview(ctx context.Context, userID, field string, userProfile map[string]interface{}, questions []string) (string, error) {
	chat := models.InterviewStructuredChat{
		ID:              primitive.NewObjectID().Hex(),
		UserID:          userID,
		Field:           field,
		UserProfile:     userProfile,
		Questions:       questions,
		Messages:        []models.InterviewStructuredMessage{},
		CurrentQuestion: 0,
		IsCompleted:     false,
		CreatedAt:       time.Now(),
		UpdatedAt:       time.Now(),
	}

	_, err := r.collection.InsertOne(ctx, chat)
	if err != nil {
		return "", fmt.Errorf("failed to start interview: %w", err)
	}

	return chat.ID, nil
}

func (r *InterviewStructuredRepository) GetInterviewChatByID(ctx context.Context, chatID string) (*models.InterviewStructuredChat, error) {
	var chat models.InterviewStructuredChat
	err := r.collection.FindOne(ctx, bson.M{"_id": chatID}).Decode(&chat)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, fmt.Errorf("interview chat not found")
		}
		return nil, fmt.Errorf("failed to get interview chat: %w", err)
	}

	return &chat, nil
}

func (r *InterviewStructuredRepository) AppendMessage(ctx context.Context, chatID string, message models.InterviewStructuredMessage) error {
	update := bson.M{
		"$push": bson.M{"messages": message},
		"$set":  bson.M{"updated_at": time.Now()},
	}

	result, err := r.collection.UpdateOne(ctx, bson.M{"_id": chatID}, update)
	if err != nil {
		return fmt.Errorf("failed to append message: %w", err)
	}

	if result.MatchedCount == 0 {
		return fmt.Errorf("interview chat not found")
	}

	return nil
}

func (r *InterviewStructuredRepository) UpdateSessionState(ctx context.Context, chatID string, currentQuestion int, isCompleted bool) error {
	update := bson.M{
		"$set": bson.M{
			"current_question": currentQuestion,
			"is_completed":     isCompleted,
			"updated_at":       time.Now(),
		},
	}

	result, err := r.collection.UpdateOne(ctx, bson.M{"_id": chatID}, update)
	if err != nil {
		return fmt.Errorf("failed to update session state: %w", err)
	}

	if result.MatchedCount == 0 {
		return fmt.Errorf("interview chat not found")
	}

	return nil
}

func (r *InterviewStructuredRepository) GetInterviewChatsByUserID(ctx context.Context, userID string) ([]*models.InterviewStructuredChat, error) {
	filter := bson.M{"user_id": userID}
	opts := options.Find().SetSort(bson.D{{Key: "created_at", Value: -1}})

	cursor, err := r.collection.Find(ctx, filter, opts)
	if err != nil {
		return nil, fmt.Errorf("failed to find user chats: %w", err)
	}
	defer cursor.Close(ctx)

	var chats []*models.InterviewStructuredChat
	for cursor.Next(ctx) {
		var chat models.InterviewStructuredChat
		if err := cursor.Decode(&chat); err != nil {
			return nil, fmt.Errorf("failed to decode chat: %w", err)
		}
		chats = append(chats, &chat)
	}

	if err := cursor.Err(); err != nil {
		return nil, fmt.Errorf("cursor error: %w", err)
	}

	return chats, nil
}


func (r *InterviewStructuredRepository) CreateInterviewChat(ctx context.Context, userID string, sessionType string) (string, error) {
	return "", fmt.Errorf("not implemented in structured repository")
}

func (r *InterviewStructuredRepository) GetInterviewChatByIDWithLimit(ctx context.Context, chatID string, limit, offset int) (*models.InterviewStructuredChat, error) {
	return nil, fmt.Errorf("not implemented in structured repository")
}

func (r *InterviewStructuredRepository) DeleteInterviewChat(ctx context.Context, chatID string) error {
	result, err := r.collection.DeleteOne(ctx, bson.M{"_id": chatID})
	if err != nil {
		return fmt.Errorf("failed to delete interview chat: %w", err)
	}

	if result.DeletedCount == 0 {
		return fmt.Errorf("interview chat not found")
	}

	return nil
}

func (r *InterviewStructuredRepository) GetInterviewChatsByUserIDWithLimit(ctx context.Context, userID string, limit, offset int) ([]*models.InterviewStructuredChat, error) {
	filter := bson.M{"user_id": userID}
	opts := options.Find().SetSort(bson.D{{Key: "created_at", Value: -1}}).SetSkip(int64(offset)).SetLimit(int64(limit))

	cursor, err := r.collection.Find(ctx, filter, opts)
	if err != nil {
		return nil, fmt.Errorf("failed to find interview chats: %w", err)
	}
	defer cursor.Close(ctx)

	var chats []*models.InterviewStructuredChat
	for cursor.Next(ctx) {
		var chat models.InterviewStructuredChat
		if err := cursor.Decode(&chat); err != nil {
			return nil, fmt.Errorf("failed to decode interview chat: %w", err)
		}
		chats = append(chats, &chat)
	}

	if err := cursor.Err(); err != nil {
		return nil, fmt.Errorf("cursor error: %w", err)
	}

	return chats, nil
}

func (r *InterviewStructuredRepository) UpdateInterviewState(ctx context.Context, chatID string, currentQuestion int, inInterview bool) error {
	objectID, err := primitive.ObjectIDFromHex(chatID)
	if err != nil {
		return fmt.Errorf("invalid chat ID format: %w", err)
	}

	update := bson.M{
		"$set": bson.M{
			"current_question": currentQuestion,
			"is_completed":     inInterview,
			"updated_at":       time.Now(),
		},
	}

	result, err := r.collection.UpdateOne(ctx, bson.M{"_id": objectID}, update)
	if err != nil {
		return fmt.Errorf("failed to update interview state: %w", err)
	}

	if result.MatchedCount == 0 {
		return fmt.Errorf("interview chat not found")
	}

	return nil
}

// GetChatHistory retrieves a structured interview chat by ID
func (r *InterviewStructuredRepository) GetChatHistory(ctx context.Context, chatID string) (*models.InterviewStructuredChat, error) {
	var chat models.InterviewStructuredChat

	err := r.collection.FindOne(ctx, bson.M{"_id": chatID}).Decode(&chat)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, fmt.Errorf("interview chat not found")
		}
		return nil, fmt.Errorf("failed to get chat history: %w", err)
	}

	return &chat, nil
}

// GetChatHistoryWithLimit retrieves a structured interview chat with message pagination
func (r *InterviewStructuredRepository) GetChatHistoryWithLimit(ctx context.Context, chatID string, limit, offset int) (*models.InterviewStructuredChat, error) {
	var chat models.InterviewStructuredChat

	// First get the basic chat info
	err := r.collection.FindOne(ctx, bson.M{"_id": chatID}).Decode(&chat)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, fmt.Errorf("interview chat not found")
		}
		return nil, fmt.Errorf("failed to get chat history: %w", err)
	}

	// Apply pagination to messages
	totalMessages := len(chat.Messages)
	if offset >= totalMessages {
		chat.Messages = []models.InterviewStructuredMessage{}
	} else {
		end := offset + limit
		if end > totalMessages {
			end = totalMessages
		}
		chat.Messages = chat.Messages[offset:end]
	}

	return &chat, nil
}

// GetUserInterviewChats retrieves all structured interview chats for a user
func (r *InterviewStructuredRepository) GetUserInterviewChats(ctx context.Context, userID string) ([]*models.InterviewStructuredChat, error) {
	cursor, err := r.collection.Find(ctx, bson.M{"user_id": userID})
	if err != nil {
		return nil, fmt.Errorf("failed to get user chats: %w", err)
	}
	defer cursor.Close(ctx)

	var chats []*models.InterviewStructuredChat
	for cursor.Next(ctx) {
		var chat models.InterviewStructuredChat
		if err := cursor.Decode(&chat); err != nil {
			return nil, fmt.Errorf("failed to decode chat: %w", err)
		}
		chats = append(chats, &chat)
	}

	if err := cursor.Err(); err != nil {
		return nil, fmt.Errorf("cursor error: %w", err)
	}

	return chats, nil
}
