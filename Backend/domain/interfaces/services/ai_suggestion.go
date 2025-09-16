package interfaces

import (
	"context"

	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
)

type AISuggestionService interface {
	Analyze(ctx context.Context, cvText string) (*models.AISuggestions, error)

	GenerateSuggestions(ctx context.Context, cv *models.CV, skillGaps []*models.SkillGap) (*models.Suggestion, error)
}
