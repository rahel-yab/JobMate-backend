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
	objectID := primitive.NewObjectID()
	
	chat := bson.M{
		"_id":              objectID,
		"user_id":          userID,
		"field":            field,
		"user_profile":     userProfile,
		"questions":        questions,
		"messages":         []bson.M{},
		"current_question": 0,
		"is_completed":     false,
		"created_at":       time.Now(),
		"updated_at":       time.Now(),
	}

	_, err := r.collection.InsertOne(ctx, chat)
	if err != nil {
		return "", fmt.Errorf("failed to start interview: %w", err)
	}

	return objectID.Hex(), nil
}

func (r *InterviewStructuredRepository) GetInterviewChatByID(ctx context.Context, chatID string) (*models.InterviewStructuredChat, error) {
	
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

func (r *InterviewStructuredRepository) convertToChat(result bson.M) *models.InterviewStructuredChat {
	var id, userID, field string
	var createdAt, updatedAt time.Time
	var currentQuestion int
	var isCompleted bool
	var questions []string
	var userProfile map[string]interface{}

	if objID, ok := result["_id"].(primitive.ObjectID); ok {
		id = objID.Hex()
	} else if strID, ok := result["_id"].(string); ok {
		id = strID
	}


	if uid, ok := result["user_id"].(string); ok {
		userID = uid
	}

	
	if f, ok := result["field"].(string); ok {
		field = f
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

	if cq, ok := result["current_question"].(int32); ok {
		currentQuestion = int(cq)
	} else if cq, ok := result["current_question"].(int); ok {
		currentQuestion = cq
	}

	
	if ic, ok := result["is_completed"].(bool); ok {
		isCompleted = ic
	}

	
	if questionsData, ok := result["questions"].(primitive.A); ok {
		for _, q := range questionsData {
			if qStr, ok := q.(string); ok {
				questions = append(questions, qStr)
			}
		}
	}

	
	if profileData, ok := result["user_profile"].(bson.M); ok {
		userProfile = make(map[string]interface{})
		for k, v := range profileData {
			userProfile[k] = v
		}
	}

	chat := &models.InterviewStructuredChat{
		ID:              id,
		UserID:          userID,
		Field:           field,
		Questions:       questions,
		UserProfile:     userProfile,
		CurrentQuestion: currentQuestion,
		IsCompleted:     isCompleted,
		CreatedAt:       createdAt,
		UpdatedAt:       updatedAt,
	}

	// Convert messages
	if messagesData, ok := result["messages"].(primitive.A); ok {
		for _, msgData := range messagesData {
			if msgMap, ok := msgData.(bson.M); ok {
				var msgID string
				var timestamp time.Time
				var questionIndex int

				
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

				
				if qi, ok := msgMap["question_index"].(int32); ok {
					questionIndex = int(qi)
				} else if qi, ok := msgMap["question_index"].(int); ok {
					questionIndex = qi
				}

				message := models.InterviewStructuredMessage{
					ID:            msgID,
					Role:          msgMap["role"].(string),
					Content:       msgMap["content"].(string),
					QuestionIndex: questionIndex,
					Timestamp:     timestamp,
				}
				chat.Messages = append(chat.Messages, message)
			}
		}
	}

	return chat
}

func (r *InterviewStructuredRepository) AppendMessage(ctx context.Context, chatID string, message models.InterviewStructuredMessage) error {
	var filter bson.M
	if objectID, err := primitive.ObjectIDFromHex(chatID); err == nil {
		filter = bson.M{"_id": objectID}
	} else {
		filter = bson.M{"_id": chatID}
	}
	
	messageBSON := bson.M{
		"_id":            primitive.NewObjectID(),
		"role":           message.Role,
		"content":        message.Content,
		"question_index": message.QuestionIndex,
		"timestamp":      message.Timestamp,
	}
	
	update := bson.M{
		"$push": bson.M{"messages": messageBSON},
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

func (r *InterviewStructuredRepository) UpdateSessionState(ctx context.Context, chatID string, currentQuestion int, isCompleted bool) error {
	var filter bson.M
	if objectID, err := primitive.ObjectIDFromHex(chatID); err == nil {
		filter = bson.M{"_id": objectID}
	} else {
		filter = bson.M{"_id": chatID}
	}
	
	update := bson.M{
		"$set": bson.M{
			"current_question": currentQuestion,
			"is_completed":     isCompleted,
			"updated_at":       time.Now(),
		},
	}

	result, err := r.collection.UpdateOne(ctx, filter, update)
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


func (r *InterviewStructuredRepository) CreateInterviewChat(ctx context.Context, userID string, sessionType string) (string, error) {
	return "", fmt.Errorf("not implemented in structured repository")
}

func (r *InterviewStructuredRepository) GetInterviewChatByIDWithLimit(ctx context.Context, chatID string, limit, offset int) (*models.InterviewStructuredChat, error) {
	return nil, fmt.Errorf("not implemented in structured repository")
}

func (r *InterviewStructuredRepository) DeleteInterviewChat(ctx context.Context, chatID string) error {
	var filter bson.M
	if objectID, err := primitive.ObjectIDFromHex(chatID); err == nil {
		filter = bson.M{"_id": objectID}
	} else {
		filter = bson.M{"_id": chatID}
	}
	
	result, err := r.collection.DeleteOne(ctx, filter)
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
		return nil, fmt.Errorf("failed to get chat history: %w", err)
	}

	return r.convertToChat(result), nil
}

// GetChatHistoryWithLimit retrieves a structured interview chat with message pagination
func (r *InterviewStructuredRepository) GetChatHistoryWithLimit(ctx context.Context, chatID string, limit, offset int) (*models.InterviewStructuredChat, error) {
	
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
			"field":            1,
			"user_profile":     1,
			"questions":        1,
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

// GetUserInterviewChats retrieves all structured interview chats for a user
func (r *InterviewStructuredRepository) GetUserInterviewChats(ctx context.Context, userID string) ([]*models.InterviewStructuredChat, error) {
	cursor, err := r.collection.Find(ctx, bson.M{"user_id": userID})
	if err != nil {
		return nil, fmt.Errorf("failed to get user chats: %w", err)
	}
	defer cursor.Close(ctx)

	var chats []*models.InterviewStructuredChat
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
