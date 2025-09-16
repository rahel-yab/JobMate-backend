import 'package:equatable/equatable.dart';

class CourseSuggestion extends Equatable {
  final String title;
  final String provider;
  final String url;
  final String description;
  final String skill;

  const CourseSuggestion({
    required this.title,
    required this.provider,
    required this.url,
    required this.description,
    required this.skill,
  });

  @override
  List<Object> get props => [title, provider, url, description, skill];
}

class Suggestion extends Equatable {
  final List<CourseSuggestion> courses;
  final List<String> generalAdvice;
  final String userId;

  const Suggestion({
    required this.courses,
    required this.generalAdvice,
    required this.userId,
  });

  @override
  List<Object> get props => [courses, generalAdvice, userId];
}