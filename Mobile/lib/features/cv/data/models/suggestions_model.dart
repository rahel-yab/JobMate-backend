import 'package:job_mate/features/cv/domain/entities/suggestion.dart';

class CourseSuggestionModel extends CourseSuggestion {
  const CourseSuggestionModel({
    required super.title,
    required super.provider,
    required super.url,
    required super.description,
    required super.skill,
  });

  factory CourseSuggestionModel.fromJson(Map<String, dynamic> json) {
    return CourseSuggestionModel(
      title: json['Title'],
      provider: json['Provider'],
      url: json['URL'],
      description: json['Description'],
      skill: json['Skill'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Provider': provider,
      'URL': url,
      'Description': description,
      'Skill': skill,
    };
  }
}

class SuggestionModel extends Suggestion {
  const SuggestionModel({
    required super.courses,
    required super.generalAdvice,
    required super.userId,
  });

  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final suggestions = data['suggestions'] as Map<String, dynamic>;
    return SuggestionModel(
      courses: (suggestions['Courses'] as List)
          .map((e) => CourseSuggestionModel.fromJson(e))
          .toList(),
      generalAdvice: List<String>.from(suggestions['GeneralAdvice'] ?? []),
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'suggestions': {
          'Courses': courses.map((e) => (e as CourseSuggestionModel).toJson()).toList(),
          'GeneralAdvice': generalAdvice,
        },
        'userId': userId,
      },
      'message': 'Suggestions generated successfully',
      'success': true,
    };
  }
}