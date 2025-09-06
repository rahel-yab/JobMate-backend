import 'package:flutter/material.dart';
import 'package:job_mate/features/cv/domain/entities/suggestion.dart';

class SuggestionCard extends StatelessWidget {
  final Suggestion suggestion;
  final ValueChanged<String>? onTap; // ✅ Added callback

  const SuggestionCard({
    super.key,
    required this.suggestion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🎓 Suggestions",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF005148)),
          ),
          const SizedBox(height: 12),

          const Text("Courses", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF005148))),
          ...suggestion.courses.map(
            (course) => InkWell(
              onTap: () => onTap?.call(course.title), // ✅ Tap suggestion
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Provider: ${course.provider}"),
                    Text("URL: ${course.url}"),
                    Text("Description: ${course.description}"),
                    Text("Skills: ${course.skill}"),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          const Text("General Advice", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF005148))),
          ...suggestion.generalAdvice.map(
            (advice) => InkWell(
              onTap: () => onTap?.call(advice), // ✅ Tap suggestion
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text("• $advice"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
