package languagedetection

import (
	

	"github.com/abadojack/whatlanggo"
	svc "github.com/tsigemariamzewdu/JobMate-backend/domain/interfaces/services"
)

type DetectionService struct{}

func NewDetectionService() svc.IlangDetection {
	return &DetectionService{}
}

// language detector
func (d *DetectionService) DetectLanguage(text string) string {
	info := whatlanggo.Detect(text)
	if info.Lang == whatlanggo.Amh {
		return "amharic"
	}
	return "english"
	//we can add more languages if possible in the future
}
