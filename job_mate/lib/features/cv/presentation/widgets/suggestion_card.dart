import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:job_mate/features/cv/domain/entities/suggestion.dart';

class SuggestionCard extends StatelessWidget {
  final Suggestion suggestion;
  final ValueChanged<String>? onTap;

  const SuggestionCard({
    super.key,
    required this.suggestion,
    this.onTap,
  });

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6F4),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Color(0xFF005148), size: 20),
              SizedBox(width: 8),
              Text(
                "Smart Suggestions",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF005148),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (suggestion.courses.isNotEmpty) ...[
            const Text(
              "📚 Recommended Courses",
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF005148)),
            ),
            const SizedBox(height: 8),
            ...suggestion.courses.map(
              (course) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              course.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.content_copy, size: 18),
                            onPressed: () => onTap?.call(course.title),
                          ),
                        ],
                      ),
                      if (course.provider.isNotEmpty)
                        Text("🏢 ${course.provider}", style: const TextStyle(fontSize: 12)),
                      if (course.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(course.description, style: const TextStyle(fontSize: 12)),
                        ),
                      if (course.skill.isNotEmpty)
                        Text("🛠️ Skills: ${course.skill}", style: const TextStyle(fontSize: 12)),
                      if (course.url.isNotEmpty)
                        GestureDetector(
                          onTap: () => _launchUrl(course.url),
                          child: Text(
                            "🔗 Open Course",
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (suggestion.generalAdvice.isNotEmpty) ...[
            const Text(
              "💡 General Advice",
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF005148)),
            ),
            const SizedBox(height: 8),
            ...suggestion.generalAdvice.map(
              (advice) => GestureDetector(
                onTap: () => onTap?.call(advice),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(child: Text(advice)),
                      const Icon(Icons.content_copy, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}