import 'package:job_mate/features/interview/data/models/interview_message_model.dart';
import 'package:job_mate/features/interview/data/models/interview_session_model.dart';

abstract class InterviewLocalDataSource {
  // Sessions
  Future<void> cacheUserFreeformChats(List<InterviewSessionModel> sessions);
  Future<List<InterviewSessionModel>> getCachedUserFreeformChats();

  Future<void> cacheUserStructuredChats(List<InterviewSessionModel> sessions);
  Future<List<InterviewSessionModel>> getCachedUserStructuredChats();

  // Histories by chatId
  Future<void> cacheFreeformHistory(String chatId, List<InterviewMessageModel> messages);
  Future<List<InterviewMessageModel>> getCachedFreeformHistory(String chatId);

  Future<void> cacheStructuredHistory(String chatId, List<InterviewMessageModel> messages);
  Future<List<InterviewMessageModel>> getCachedStructuredHistory(String chatId);

  // Clear
  Future<void> clearAllInterviewCache();
}


