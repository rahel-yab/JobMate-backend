import 'package:job_mate/features/interview/data/models/interview_message_model.dart';
import 'package:job_mate/features/interview/data/models/interview_session_model.dart';

abstract class InterviewRemoteDataSource {
  // Freeform
  Future<InterviewSessionModel> startFreeformSession(String sessionType);
  Future<InterviewMessageModel> sendFreeformMessage(
    String chatId,
    String message,
  );
  Future<List<InterviewMessageModel>> getFreeformHistory(String chatId);
  Future<List<InterviewSessionModel>> getUserFreeformChats();

  // Structured
  Future<InterviewSessionModel> startStructuredInterview(String field);
  Future<InterviewMessageModel> continueStructuredInterview(String chatId);
  Future<InterviewMessageModel> answerStructuredInterview(
    String chatId,
    String answer,
  );
  Future<List<InterviewMessageModel>> getStructuredHistory(String chatId);
  Future<List<InterviewSessionModel>> getUserStructuredChats();
}
