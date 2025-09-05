import 'package:dio/dio.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:job_mate/features/cv/data/datasources/remote/cv_chat_remote_data_source.dart';

import 'package:job_mate/features/cv/data/models/chat_session_model.dart';
import 'package:job_mate/features/cv/data/models/chat_message_model.dart';
import 'package:job_mate/features/cv/domain/entities/chat_message.dart';
import 'package:job_mate/features/cv/domain/entities/chat_session.dart';

class CvChatRemoteDataSourceImpl extends CvChatRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource authLocalDataSource;

  CvChatRemoteDataSourceImpl({required this.dio, required this.authLocalDataSource});

  @override
  Future<String> createChatSession(String? cvId) async {
    try {
      final token = await authLocalDataSource.getAccessToken();
      final response = await dio.post(
        '/cv/chat/session',
        data: cvId != null ? {'cv_id': cvId} : {},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['chat_id'];
    } catch (e) {
      throw ServerFailure('Failed to create chat session: $e');
    }
  }

  @override
  Future<ChatMessage> sendChatMessage(String chatId, String message, String? cvId) async {
    try {
      final token = await authLocalDataSource.getAccessToken();
      final response = await dio.post(
        '/cv/chat/message',
        data: {'chat_id': chatId, 'message': message, if (cvId != null) 'cv_id': cvId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return ChatMessageModel.fromJson(response.data);
    } catch (e) {
      throw ServerFailure('Failed to send chat message: $e');
    }
  }

  @override
  Future<ChatSession> getChatHistory(String chatId) async {
    try {
      final token = await authLocalDataSource.getAccessToken();
      final response = await dio.get(
        '/cv/chat/$chatId/history',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return ChatSessionModel.fromJson(response.data);
    } catch (e) {
      throw ServerFailure('Failed to get chat history: $e');
    }
  }

  @override
  Future<List<ChatSession>> getAllChatSessions() async {
    try {
      final token = await authLocalDataSource.getAccessToken();
      final response = await dio.get(
        '/cv/chat/user',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return (response.data as List).map((e) => ChatSessionModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerFailure('Failed to get all chat sessions: $e');
    }
  }
}