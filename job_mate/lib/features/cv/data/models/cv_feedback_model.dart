import 'package:job_mate/features/cv/domain/entities/cv_feedback.dart';

class SkillGapModel extends SkillGap{
  const SkillGapModel({
    required super.skillName, 
    required super.currentLevel, 
    required super.recommendedLevel, 
    required super.importance, 
    required super.improvementSuggestions});

  factory SkillGapModel.fromJson(Map<String,dynamic> json){
    return SkillGapModel(
      skillName: json['skillName'] as String,
      currentLevel: json['currentLevel'] as int,
      recommendedLevel: json['recommendedLevel'] as int,
      importance: json['importance'] as String,
      improvementSuggestions: json['improvementSuggestions'] as String,
    );
  }
  Map<String,dynamic> toJson(){
    return{
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
        required super.summary,
        required super.strengths,
        required super.weaknesses,
        required super.improvementSuggestions,
        super.skillGaps,
      });

      factory CvFeedbackModel.fromJson(Map<String, dynamic> json) {
        final suggestions = json['suggestions'] as Map<String, dynamic>;
        final cvFeedback = suggestions['CVFeedback'] as Map<String, dynamic>;
        final skillGaps = (json['SkillGaps'] as List<dynamic>?)
            ?.map((item) => SkillGapModel.fromJson(item as Map<String, dynamic>))
            .toList();

        return CvFeedbackModel(
          extractedSkills: List<String>.from(suggestions['CVs']['extractedSkills']),
          extractedExperience: List<String>.from(suggestions['CVs']['extractedExperience']),
          extractedEducation: List<String>.from(suggestions['CVs']['extractedEducation']),
          summary: suggestions['CVs']['summary'] as String,
          strengths: cvFeedback['strengths'] as String,
          weaknesses: cvFeedback['weaknesses'] as String,
          improvementSuggestions: cvFeedback['improvementSuggestions'] as String,
          skillGaps: skillGaps?.cast<SkillGap>(),
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