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

  // @override
  // Future<ChatMessage> sendChatMessage(String chatId, String message, String? cvId) async {
  //   try {
  //     final token = await authLocalDataSource.getAccessToken();
  //     final response = await dio.post(
  //       '/cv/chat/message',
  //       data: {'chat_id': chatId, 'message': message, if (cvId != null) 'cv_id': cvId},
  //       options: Options(headers: {'Authorization': 'Bearer $token'}),
  //     );
  //     return ChatMessageModel.fromJson(response.data);
  //   } catch (e) {
  //     throw ServerFailure('Failed to send chat message: $e');
  //   }
  // }
  // In CvChatRemoteDataSourceImpl, update the sendChatMessage method:
@override
Future<ChatMessage> sendChatMessage(String chatId, String message, String? cvId) async {
  try {
    final token = await authLocalDataSource.getAccessToken();
    if (token == null) {
      throw ServerFailure('No authentication token available');
    }

    // Debug print
    print('=== API REQUEST DETAILS ===');
    print('Endpoint: /cv/chat/$chatId/message');
    print('Headers: Authorization: Bearer $token');
    print('Body: {');
    print('  "message": "$message"');
    if (cvId != null) print('  "cv_id": "$cvId"');
    print('}');

    final response = await dio.post(
      '/cv/chat/$chatId/message',  // Chat ID as URL parameter
      data: {
        'message': message,
        if (cvId != null) 'cv_id': cvId,  // cv_id is optional in body
      },
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    // Debug print
    print('=== API RESPONSE ===');
    print('Status: ${response.statusCode}');
    print('Data: ${response.data}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ChatMessageModel.fromJson(response.data);
    } else {
      throw ServerFailure('Failed to send message: ${response.statusCode}');
    }
  } catch (e) {
    print('Error in sendChatMessage: $e');
    if (e is DioException) {
      if (e.response != null) {
        print('Dio Error Response: ${e.response?.data}');
        print('Dio Error Status: ${e.response?.statusCode}');
        print('Dio Error Headers: ${e.response?.headers}');
      }
      if (e.type == DioExceptionType.badResponse) {
        throw ServerFailure('Server error: ${e.response?.statusCode}');
      }
    }
    throw ServerFailure('Failed to send chat message: $e');
  }
}

 @override
Future<ChatSession> getChatHistory(String chatId) async {
  try {
    final token = await authLocalDataSource.getAccessToken();
    
    print('=== GET CHAT HISTORY REQUEST ===');
    print('Endpoint: /cv/chat/$chatId/history');
    print('Headers: Authorization: Bearer $token');
    
    final response = await dio.get(
      '/cv/chat/$chatId/history',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    
    print('=== CHAT HISTORY RESPONSE ===');
    print('Status: ${response.statusCode}');
    print('Data: ${response.data}');
    
    return ChatSessionModel.fromJson(response.data);
  } catch (e) {
    print('Error in getChatHistory: $e');
    if (e is DioException) {
      print('Dio Error: ${e.response?.data}');
    }
    throw ServerFailure('Failed to get chat history: $e');
  }
}

@override
Future<List<ChatSession>> getAllChatSessions() async {
  try {
    final token = await authLocalDataSource.getAccessToken();
    
    print('=== GET ALL CHAT SESSIONS REQUEST ===');
    print('Endpoint: /cv/chat/user');
    print('Headers: Authorization: Bearer $token');
    
    final response = await dio.get(
      '/cv/chat/user',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    
    print('=== ALL CHAT SESSIONS RESPONSE ===');
    print('Status: ${response.statusCode}');
    print('Data: ${response.data}');
    
    return (response.data as List).map((e) => ChatSessionModel.fromJson(e)).toList();
  } catch (e) {
    print('Error in getAllChatSessions: $e');
    if (e is DioException) {
      print('Dio Error: ${e.response?.data}');
    }
    throw ServerFailure('Failed to get all chat sessions: $e');
  }
}
}