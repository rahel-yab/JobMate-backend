import 'package:equatable/equatable.dart';

class SkillGap extends Equatable{
  final String skillName;
  final int currentLevel;
  final int recommendedLevel;
  final String importance;
  final String improvementSuggestions;

  const SkillGap({
    required this.skillName, 
    required this.currentLevel, 
    required this.recommendedLevel, 
    required this.importance, 
    required this.improvementSuggestions, 
  });
  
  @override
  
  List<Object?> get props => [skillName,currentLevel,recommendedLevel,importance,improvementSuggestions];
}

class CvFeedback extends Equatable{
  final List<String> extractedSkills;
  final List<String> extractedExperience;
  final List<String> extractedEducation;
  final String summary;
  final String strengths;
  final String weaknesses;
  final String improvementSuggestions;
  final List<SkillGap>? skillGaps;

  const CvFeedback({
    required this.extractedSkills,
    required this.extractedExperience,
    required this.extractedEducation,
    required this.summary,
    required this.strengths,
    required this.weaknesses,
    required this.improvementSuggestions,
    this.skillGaps,
  });
  
  @override
  
  List<Object?> get props => [extractedSkills,extractedExperience,extractedEducation,summary,strengths,weaknesses,improvementSuggestions,skillGaps];
}