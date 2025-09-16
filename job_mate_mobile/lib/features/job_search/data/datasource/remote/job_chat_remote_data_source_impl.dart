import 'package:dio/dio.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:job_mate/features/job_search/data/datasource/remote/job_chat_remote_data_source.dart';
import 'package:job_mate/features/job_search/data/models/chat_model.dart';
import 'package:job_mate/features/job_search/domain/entities/chat.dart';

class JobChatRemoteDataSourceImpl implements JobChatRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource authLocalDataSource;

  JobChatRemoteDataSourceImpl({
    required this.dio,
    required this.authLocalDataSource,
  });

  @override
  Future<List<Chat>> getAllChats() async {
    try {
      final token = await authLocalDataSource.getAccessToken();
      if (token == null) throw ServerFailure('No authentication token available');

      print("📡 Sending GET request → /jobs/chats");

      final response = await dio.get(
        '/jobs/chats',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print("✅ Status Code: ${response.statusCode}");
      print("📥 Response Data: ${response.data}");

      if (response.data == null || response.data is! List) {
        throw ServerFailure('Unexpected response format: ${response.data}');
      }

      return (response.data as List)
          .map((json) => ChatModel.fromJson(json))
          .toList();
    } catch (e) {
      if (e is DioException) {
        print("❌ DioException on getAllChats → ${e.response}");
        if (e.response?.statusCode == 401) {
          throw ServerFailure('Unauthorized: Please log in again');
        }
      }
      throw ServerFailure('Failed to get chats: $e');
    }
  }

  @override
  Future<Chat> getChatById(String id) async {
    try {
      final token = await authLocalDataSource.getAccessToken();
      if (token == null) throw ServerFailure('No authentication token available');

      print("📡 Sending GET request → /jobs/chat/$id");

      final response = await dio.get(
        '/jobs/chat/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print("✅ Status Code: ${response.statusCode}");
      print("📥 Response Data: ${response.data}");

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw ServerFailure('Unexpected response format: ${response.data}');
      }

      return ChatModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        print("❌ DioException on getChatById → ${e.response}");
        if (e.response?.statusCode == 401) {
          throw ServerFailure('Unauthorized: Please log in again');
        } else if (e.response?.statusCode == 404) {
          throw ServerFailure('Chat not found');
        }
      }
      throw ServerFailure('Failed to get chat: $e');
    }
  }

  ///  Updated: return raw Map instead of ChatModel
  // In JobChatRemoteDataSourceImpl, update the sendChatMessage method
@override
Future<Map<String, dynamic>> sendChatMessage(String message, {String? chatId}) async {
  try {
    final token = await authLocalDataSource.getAccessToken();
    if (token == null) throw ServerFailure('No authentication token available');

    final requestData = {
      'message': message,
      if (chatId != null) 'chat_id': chatId,
    };

    print("📡 Sending POST request → /jobs/chat");
    print("📝 Request Body: $requestData");

    final response = await dio.post(
      '/jobs/chat',
      data: requestData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    print("✅ Status Code: ${response.statusCode}");
    print("📥 Response Data: ${response.data}");

    if (response.data == null || response.data is! Map<String, dynamic>) {
      throw ServerFailure('Unexpected response format: ${response.data}');
    }

    // The API returns: {message: "text", jobs: [], chat_id: "id"}
    return response.data as Map<String, dynamic>;
  } catch (e) {
    if (e is DioException) {
      print("❌ DioException on sendChatMessage → ${e.response}");
      if (e.response?.statusCode == 400) {
        throw ServerFailure(
            'Invalid request: ${e.response?.data['message'] ?? e.message}');
      } else if (e.response?.statusCode == 401) {
        throw ServerFailure('Unauthorized: Please log in again');
      }
    }
    throw ServerFailure('Failed to send chat message: $e');
  }
}
}
