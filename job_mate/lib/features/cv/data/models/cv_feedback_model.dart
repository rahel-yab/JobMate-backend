import 'package:job_mate/features/cv/domain/entities/cv_feedback.dart';
class SkillGapModel extends SkillGap {
  const SkillGapModel({
    super.skillName,
    super.currentLevel,
    super.recommendedLevel,
    super.importance,
    super.improvementSuggestions,
  });

  factory SkillGapModel.fromJson(Map<String, dynamic> json) {
    return SkillGapModel(
      skillName: json['skillName'] as String?,               // nullable
      currentLevel: json['currentLevel'] as int?,            // nullable
      recommendedLevel: json['recommendedLevel'] as int?,    // nullable
      importance: json['importance'] as String?,             // nullable
      improvementSuggestions: json['improvementSuggestions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skillName': skillName,
      'currentLevel': currentLevel,
      'recommendedLevel': recommendedLevel,
      'importance': importance,
      'improvementSuggestions': improvementSuggestions,
    };
  }
}

class CvFeedbackModel extends CvFeedback {
  const CvFeedbackModel({
    required super.extractedSkills,
    required super.extractedExperience,
    required super.extractedEducation,
    super.summary,
    super.strengths,
    super.weaknesses,
    super.improvementSuggestions,
    super.skillGaps,
  });

  factory CvFeedbackModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final suggestions = data['suggestions'] as Map<String, dynamic>? ?? {};
    final cvFeedback = suggestions['CVFeedback'] as Map<String, dynamic>? ?? {};
    final cVs = suggestions['CVs'] as Map<String, dynamic>? ?? {};
    final skillGaps = (suggestions['SkillGaps'] as List<dynamic>?)
        ?.map((item) => SkillGapModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return CvFeedbackModel(
      extractedSkills: List<String>.from(cVs['ExtractedSkills'] ?? []),
      extractedExperience: List<String>.from(cVs['ExtractedExperience'] ?? []),
      extractedEducation: List<String>.from(cVs['ExtractedEducation'] ?? []),
      summary: cVs['Summary'] as String?,
      strengths: cvFeedback['Strengths'] as String?,
      weaknesses: cvFeedback['Weaknesses'] as String?,
      improvementSuggestions: cvFeedback['ImprovementSuggestions'] as String?,
      skillGaps: skillGaps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'extractedSkills': extractedSkills,
      'extractedExperience': extractedExperience,
      'extractedEducation': extractedEducation,
      'summary': summary,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'improvementSuggestions': improvementSuggestions,
      'skillGaps': skillGaps?.map((gap) => (gap as SkillGapModel).toJson()).toList(),
    };
  }
}