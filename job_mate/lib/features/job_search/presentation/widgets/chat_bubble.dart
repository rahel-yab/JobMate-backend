import 'package:flutter/material.dart';
import 'package:job_mate/features/job_search/domain/entities/job.dart';
import 'package:job_mate/features/job_search/presentation/widgets/job_suggestion.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final List<Job>? jobs;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.jobs,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUser 
              ? const Color(0xFF005148)
              : Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: isUser ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            if (!isUser && jobs != null && jobs!.isNotEmpty) ...[
              const SizedBox(height: 16),
              JobSuggestionWidget(jobs: jobs!),
            ],
          ],
        ),
      ),
    );
  }
}