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
	// Try to convert chatID to ObjectID first, if it fails, use as string
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
	var id, userID, sessionType string
	var createdAt, updatedAt time.Time

	
	if objID, ok := result["_id"].(primitive.ObjectID); ok {
		id = objID.Hex()
	} else if strID, ok := result["_id"].(string); ok {
		id = strID
	}


	if uid, ok := result["user_id"].(string); ok {
		userID = uid
	}

	
	if st, ok := result["session_type"].(string); ok {
		sessionType = st
	}

	
	if ca, ok := result["created_at"].(primitive.DateTime); ok {
		createdAt = ca.Time()
	} else if ca, ok := result["created_at"].(time.Time); ok {
		createdAt = ca
	}

	
	if ua, ok := result["updated_at"].(primitive.DateTime); ok {
		updatedAt = ua.Time()
	} else if ua, ok := result["updated_at"].(time.Time); ok {
		updatedAt = ua
	}

	chat := &models.InterviewFreeformChat{
		ID:          id,
		UserID:      userID,
		SessionType: sessionType,
		CreatedAt:   createdAt,
		UpdatedAt:   updatedAt,
	}

	
	if messagesData, ok := result["messages"].(primitive.A); ok {
		for _, msgData := range messagesData {
			if msgMap, ok := msgData.(bson.M); ok {
				var msgID string
				var timestamp time.Time

				if objID, ok := msgMap["_id"].(primitive.ObjectID); ok {
					msgID = objID.Hex()
				} else if strID, ok := msgMap["_id"].(string); ok {
					msgID = strID
				}

				
				if ts, ok := msgMap["timestamp"].(primitive.DateTime); ok {
					timestamp = ts.Time()
				} else if ts, ok := msgMap["timestamp"].(time.Time); ok {
					timestamp = ts
				}

				message := models.InterviewFreeformMessage{
					ID:        msgID,
					Role:      msgMap["role"].(string),
					Content:   msgMap["content"].(string),
					Timestamp: timestamp,
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


