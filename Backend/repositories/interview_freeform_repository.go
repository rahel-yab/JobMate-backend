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

type InterviewFreeformRepository struct {
	collection *mongo.Collection
}

func NewInterviewFreeformRepository(db *mongo.Database) repositories.IInterviewFreeformRepository {
	return &InterviewFreeformRepository{
		collection: db.Collection("interview_freeform_chats"),
	}
}

func (r *InterviewFreeformRepository) CreateInterviewChat(ctx context.Context, userID string, sessionType string) (string, error) {
	chat := models.InterviewFreeformChat{
		ID:          primitive.NewObjectID().Hex(),
		UserID:      userID,
		SessionType: sessionType,
		Messages:    []models.InterviewFreeformMessage{},
		// CurrentQuestion and IsCompleted not needed for freeform chats
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	_, err := r.collection.InsertOne(ctx, chat)
	if err != nil {
		return "", fmt.Errorf("failed to create interview chat: %w", err)
	}

	return chat.ID, nil
}

func (r *InterviewFreeformRepository) GetInterviewChatByID(ctx context.Context, chatID string) (*models.InterviewFreeformChat, error) {
	var chat models.InterviewFreeformChat
	err := r.collection.FindOne(ctx, bson.M{"_id": chatID}).Decode(&chat)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, fmt.Errorf("interview chat not found")
		}
		return nil, fmt.Errorf("failed to get interview chat: %w", err)
	}

	return &chat, nil
}

func (r *InterviewFreeformRepository) GetInterviewChatByIDWithLimit(ctx context.Context, chatID string, limit, offset int) (*models.InterviewFreeformChat, error) {
	pipeline := []bson.M{
		{"$match": bson.M{"_id": chatID}},
		{"$project": bson.M{
			"_id":              1,
			"user_id":          1,
			"session_type":     1,
			"current_question": 1,
			"is_completed":     1,
			"created_at":       1,
			"updated_at":       1,
			"messages": bson.M{
				"$slice": []interface{}{"$messages", offset, limit},
			},
		}},
	}

	cursor, err := r.collection.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, fmt.Errorf("failed to aggregate chat: %w", err)
	}
	defer cursor.Close(ctx)

	var chats []models.InterviewFreeformChat
	if err = cursor.All(ctx, &chats); err != nil {
		return nil, fmt.Errorf("failed to decode chat: %w", err)
	}

	if len(chats) == 0 {
		return nil, fmt.Errorf("interview chat not found")
	}

	return &chats[0], nil
}

func (r *InterviewFreeformRepository) AppendMessage(ctx context.Context, chatID string, message models.InterviewFreeformMessage) error {
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



func (r *InterviewFreeformRepository) GetInterviewChatsByUserID(ctx context.Context, userID string) ([]*models.InterviewFreeformChat, error) {
	filter := bson.M{"user_id": userID}
	opts := options.Find().SetSort(bson.D{{Key: "created_at", Value: -1}})

	cursor, err := r.collection.Find(ctx, filter, opts)
	if err != nil {
		return nil, fmt.Errorf("failed to find user chats: %w", err)
	}
	defer cursor.Close(ctx)

	var chats []*models.InterviewFreeformChat
	for cursor.Next(ctx) {
		var chat models.InterviewFreeformChat
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



func (r *InterviewFreeformRepository) DeleteInterviewChat(ctx context.Context, chatID string) error {
	result, err := r.collection.DeleteOne(ctx, bson.M{"_id": chatID})
	if err != nil {
		return fmt.Errorf("failed to delete interview chat: %w", err)
	}

	if result.DeletedCount == 0 {
		return fmt.Errorf("interview chat not found")
	}

	return nil
}

func (r *InterviewFreeformRepository) GetInterviewChatsByUserIDWithLimit(ctx context.Context, userID string, offset int, limit int) ([]*models.InterviewFreeformChat, error) {
	filter := bson.M{"user_id": userID}
	opts := options.Find().SetSort(bson.D{{Key: "created_at", Value: -1}}).SetSkip(int64(offset)).SetLimit(int64(limit))

	cursor, err := r.collection.Find(ctx, filter, opts)
	if err != nil {
		return nil, fmt.Errorf("failed to find interview chats: %w", err)
	}
	defer cursor.Close(ctx)

	var chats []*models.InterviewFreeformChat
	for cursor.Next(ctx) {
		var chat models.InterviewFreeformChat
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


