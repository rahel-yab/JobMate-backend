package repositories

import (
	"context"
	"fmt"
	"time"

	interfaces "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/repositories"
	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

type CVChatRepository struct {
	collection *mongo.Collection
}

func NewCVChatRepository(db *mongo.Database) interfaces.ICVChatRepository {
	return &CVChatRepository{
		collection: db.Collection("cv_chats"),
	}
}

func (r *CVChatRepository) CreateCVChat(ctx context.Context, userID string, cvID string) (string, error) {
	chat := bson.M{
		"user_id":    userID,
		"cv_id":      cvID,
		"messages":   []bson.M{},
		"created_at": time.Now(),
		"updated_at": time.Now(),
	}
	
	result, err := r.collection.InsertOne(ctx, chat)
	if err != nil {
		return "", err
	}
	
	id := result.InsertedID.(primitive.ObjectID).Hex()
	return id, nil
}

func (r *CVChatRepository) AppendMessage(ctx context.Context, chatID string, message models.CVChatMessage) error {
	objID, err := primitive.ObjectIDFromHex(chatID)
	if err != nil {
		return err
	}
	
	dbMessage := bson.M{
		"_id":       primitive.NewObjectID(),
		"role":      message.Role,
		"content":   message.Content,
		"timestamp": time.Now(),
	}
	
	update := bson.M{
		"$push": bson.M{"messages": dbMessage},
		"$set":  bson.M{"updated_at": time.Now()},
	}
	
	_, err = r.collection.UpdateByID(ctx, objID, update)
	return err
}

func (r *CVChatRepository) GetCVChatByID(ctx context.Context, chatID string) (*models.CVChat, error) {
	objID, err := primitive.ObjectIDFromHex(chatID)
	if err != nil {
		return nil, err
	}
	
	var result bson.M
	err = r.collection.FindOne(ctx, bson.M{"_id": objID}).Decode(&result)
	if err != nil {
		return nil, err
	}
	
	return r.convertToChat(result), nil
}

func (r *CVChatRepository) GetCVChatByIDWithLimit(ctx context.Context, chatID string, limit int, offset int) (*models.CVChat, error) {
	objID, err := primitive.ObjectIDFromHex(chatID)
	if err != nil {
		return nil, err
	}

	// Use aggregation pipeline to limit messages
	pipeline := []bson.M{
		{"$match": bson.M{"_id": objID}},
		{"$addFields": bson.M{
			"messages": bson.M{
				"$slice": []interface{}{"$messages", offset, limit},
			},
		}},
	}

	cursor, err := r.collection.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	if cursor.Next(ctx) {
		var result bson.M
		if err := cursor.Decode(&result); err != nil {
			return nil, err
		}
		return r.convertToChat(result), nil
	}

	return nil, fmt.Errorf("chat not found")
}

func (r *CVChatRepository) GetCVChatsByUserID(ctx context.Context, userID string) ([]*models.CVChat, error) {
	filter := bson.M{"user_id": userID}
	cursor, err := r.collection.Find(ctx, filter)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var chats []*models.CVChat
	for cursor.Next(ctx) {
		var result bson.M
		if err := cursor.Decode(&result); err != nil {
			continue
		}
		chats = append(chats, r.convertToChat(result))
	}

	return chats, nil
}

func (r *CVChatRepository) GetCVChatsByUserIDWithLimit(ctx context.Context, userID string, limit int, offset int) ([]*models.CVChat, error) {
	// Use aggregation pipeline to limit messages in each chat
	pipeline := []bson.M{
		{"$match": bson.M{"user_id": userID}},
		{"$addFields": bson.M{
			"messages": bson.M{
				"$slice": []interface{}{"$messages", offset, limit},
			},
		}},
		{"$skip": offset},
		{"$limit": limit},
	}

	cursor, err := r.collection.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var chats []*models.CVChat
	for cursor.Next(ctx) {
		var result bson.M
		if err := cursor.Decode(&result); err != nil {
			continue
		}
		chats = append(chats, r.convertToChat(result))
	}

	return chats, nil
}

func (r *CVChatRepository) DeleteCVChat(ctx context.Context, chatID string) error {
	objID, err := primitive.ObjectIDFromHex(chatID)
	if err != nil {
		return err
	}
	
	_, err = r.collection.DeleteOne(ctx, bson.M{"_id": objID})
	return err
}

// convertToChat converts bson.M to domain model
func (r *CVChatRepository) convertToChat(result bson.M) *models.CVChat {
	chat := &models.CVChat{
		ID:        result["_id"].(primitive.ObjectID).Hex(),
		UserID:    result["user_id"].(string),
		CreatedAt: result["created_at"].(primitive.DateTime).Time(),
		UpdatedAt: result["updated_at"].(primitive.DateTime).Time(),
	}
	
	if cvID, ok := result["cv_id"].(string); ok {
		chat.CVID = cvID
	}
	
	if messagesRaw, ok := result["messages"].(primitive.A); ok {
		var messages []models.CVChatMessage
		for _, msgRaw := range messagesRaw {
			if msgMap, ok := msgRaw.(bson.M); ok {
				msg := models.CVChatMessage{
					ID:        msgMap["_id"].(primitive.ObjectID).Hex(),
					Role:      msgMap["role"].(string),
					Content:   msgMap["content"].(string),
					Timestamp: msgMap["timestamp"].(primitive.DateTime).Time(),
				}
				messages = append(messages, msg)
			}
		}
		chat.Messages = messages
	}
	
	return chat
}
