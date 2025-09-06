import 'package:job_mate/features/cv/domain/entities/chat_session.dart';
import 'package:job_mate/features/cv/domain/entities/cv_feedback.dart';

abstract class CvLocalDataSource {
  Future<void> cacheCvFeedback(String userId, String cvId, CvFeedback feedback);
  Future<CvFeedback?> getCvFeedback(String userId, String cvId);
  Future<List<CvFeedback>> getAllCvFeedback(String userId);
  Future<void> cacheChatSession(String userId, ChatSession session);
  Future<List<ChatSession>> getAllChatSessions(String userId);
  Future<void> clearCvData(String userId);
}