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
	objectID := primitive.NewObjectID()
	
	chat := bson.M{
		"_id":          objectID,
		"user_id":      userID,
		"session_type": sessionType,
		"messages":     []models.InterviewFreeformMessage{},
		"created_at":   time.Now(),
		"updated_at":   time.Now(),
	}

	_, err := r.collection.InsertOne(ctx, chat)
	if err != nil {
		return "", fmt.Errorf("failed to create interview chat: %w", err)
	}

	return objectID.Hex(), nil
}

func (r *InterviewFreeformRepository) GetInterviewChatByID(ctx context.Context, chatID string) (*models.InterviewFreeformChat, error) {
	var filter bson.M
	if objectID, err := primitive.ObjectIDFromHex(chatID); err == nil {
		filter = bson.M{"_id": objectID}
	} else {
		filter = bson.M{"_id": chatID}
	}
	
	var result bson.M
	err := r.collection.FindOne(ctx, filter).Decode(&result)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return nil, fmt.Errorf("interview chat not found")
		}
		return nil, fmt.Errorf("failed to get interview chat: %w", err)
	}

	return r.convertToChat(result), nil
}

func (r *InterviewFreeformRepository) convertToChat(result bson.M) *models.InterviewFreeformChat {
	chat := &models.InterviewFreeformChat{}

	// Convert ID
	if id, ok := result["_id"].(primitive.ObjectID); ok {
		chat.ID = id.Hex()
	}

	// Convert UserID
	if userID, ok := result["user_id"].(string); ok {
		chat.UserID = userID
	}

	// Convert SessionType
	if sessionType, ok := result["session_type"].(string); ok {
		chat.SessionType = sessionType
	}

	// Convert CreatedAt
	if createdAt, ok := result["created_at"].(primitive.DateTime); ok {
		chat.CreatedAt = createdAt.Time()
	}

	// Convert UpdatedAt
	if updatedAt, ok := result["updated_at"].(primitive.DateTime); ok {
		chat.UpdatedAt = updatedAt.Time()
	}

	// Convert messages
	if messagesData, ok := result["messages"].(primitive.A); ok {
		for _, msgData := range messagesData {
			if msgMap, ok := msgData.(bson.M); ok {
				message := models.InterviewFreeformMessage{}

				if msgID, ok := msgMap["_id"].(primitive.ObjectID); ok {
					message.ID = msgID.Hex()
				} else if msgID, ok := msgMap["_id"].(string); ok {
					message.ID = msgID
				}

				if role, ok := msgMap["role"].(string); ok {
					message.Role = role
				}

				if content, ok := msgMap["content"].(string); ok {
					message.Content = content
				}

				if timestamp, ok := msgMap["timestamp"].(primitive.DateTime); ok {
					message.Timestamp = timestamp.Time()
				}

				chat.Messages = append(chat.Messages, message)
			}
		}
	}

	return chat
}

func (r *InterviewFreeformRepository) GetInterviewChatByIDWithLimit(ctx context.Context, chatID string, limit, offset int) (*models.InterviewFreeformChat, error) {
	var matchFilter bson.M
	if objectID, err := primitive.ObjectIDFromHex(chatID); err == nil {
		matchFilter = bson.M{"_id": objectID}
	} else {
		matchFilter = bson.M{"_id": chatID}
	}
	
	pipeline := []bson.M{
		{"$match": matchFilter},
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

	var results []bson.M
	if err = cursor.All(ctx, &results); err != nil {
		return nil, fmt.Errorf("failed to decode chat: %w", err)
	}

	if len(results) == 0 {
		return nil, fmt.Errorf("interview chat not found")
	}

	return r.convertToChat(results[0]), nil
}

func (r *InterviewFreeformRepository) AppendMessage(ctx context.Context, chatID string, message models.InterviewFreeformMessage) error {
	
	var filter bson.M
	if objectID, err := primitive.ObjectIDFromHex(chatID); err == nil {
		filter = bson.M{"_id": objectID}
	} else {
		filter = bson.M{"_id": chatID}
	}
	
	// Convert message to BSON format
	dbMessage := bson.M{
		"_id":       primitive.NewObjectID(),
		"role":      message.Role,
		"content":   message.Content,
		"timestamp": message.Timestamp,
	}
	
	update := bson.M{
		"$push": bson.M{"messages": dbMessage},
		"$set":  bson.M{"updated_at": time.Now()},
	}

	result, err := r.collection.UpdateOne(ctx, filter, update)
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
		var result bson.M
		if err := cursor.Decode(&result); err != nil {
			return nil, fmt.Errorf("failed to decode chat: %w", err)
		}
		chats = append(chats, r.convertToChat(result))
	}

	if err := cursor.Err(); err != nil {
		return nil, fmt.Errorf("cursor error: %w", err)
	}

	return chats, nil
}

// StartInterview not needed for freeform interviews

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
		var result bson.M
		if err := cursor.Decode(&result); err != nil {
			return nil, fmt.Errorf("failed to decode interview chat: %w", err)
		}
		chats = append(chats, r.convertToChat(result))
	}

	if err := cursor.Err(); err != nil {
		return nil, fmt.Errorf("cursor error: %w", err)
	}

	return chats, nil
}


