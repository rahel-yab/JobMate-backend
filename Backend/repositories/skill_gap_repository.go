package repositories

import (
	"context"
		repo "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/repositories"
	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"

	"go.mongodb.org/mongo-driver/mongo"
)

type skillGapRepository struct {
	collection *mongo.Collection
}

func NewSkillGapRepository(db *mongo.Database) repo.SkillGapRepository {
	return &skillGapRepository{
		collection: db.Collection("skill_gaps"),
	}
}

func (r *skillGapRepository) CreateMany(ctx context.Context, gaps []*models.SkillGap) error {
	var docs []interface{}
	for _, g := range gaps {
		docs = append(docs, map[string]interface{}{
			"user_id":                  g.UserID,
			"skill_name":               g.SkillName,
			"current_level":            g.CurrentLevel,
			"recommended_level":        g.RecommendedLevel,
			"importance":               g.Importance,
			"improvement_suggestions":  g.ImprovementSuggestions,
			"created_at":               g.CreatedAt,
			"updated_at":               g.UpdatedAt,
		})
	}

	if len(docs) == 0 {
		return nil
	}

	_, err := r.collection.InsertMany(ctx, docs)
	return err
}


func (r *skillGapRepository) GetByUserID(ctx context.Context, userID string) ([]*models.SkillGap, error) {
	filter := map[string]interface{}{
		"user_id": userID,
	}

	cursor, err := r.collection.Find(ctx, filter)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var gaps []*models.SkillGap
	for cursor.Next(ctx) {
		var g models.SkillGap
		if err := cursor.Decode(&g); err != nil {
			return nil, err
		}
		gaps = append(gaps, &g)
	}

	if err := cursor.Err(); err != nil {
		return nil, err
	}

	return gaps, nil
}
