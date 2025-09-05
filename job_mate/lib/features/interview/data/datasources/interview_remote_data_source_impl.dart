import 'package:dio/dio.dart';
import 'package:job_mate/features/interview/data/datasources/interview_remote_data_source.dart';
import 'package:job_mate/features/interview/data/models/interview_message_model.dart';
import 'package:job_mate/features/interview/data/models/interview_session_model.dart';

class InterviewRemoteDataSourceImpl implements InterviewRemoteDataSource {
  final Dio dio;

  InterviewRemoteDataSourceImpl({required this.dio});

  @override
  Future<InterviewSessionModel> startFreeformSession(String sessionType) async {
    final response = await dio.post('/interview/freeform/session', data: {
      'session_type': sessionType,
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      return InterviewSessionModel.fromFreeformJson(response.data as Map<String, dynamic>);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to start freeform session: ${response.statusCode}',
    );
  }

  @override
  Future<InterviewMessageModel> sendFreeformMessage(String chatId, String message) async {
    final response = await dio.post('/interview/freeform/message', data: {
      'chat_id': chatId,
      'message': message,
    });
    if (response.statusCode == 200) {
      return InterviewMessageModel.fromJson(response.data as Map<String, dynamic>, chatId);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to send freeform message: ${response.statusCode}',
    );
  }

  @override
  Future<List<InterviewMessageModel>> getFreeformHistory(String chatId) async {
    final response = await dio.get('/interview/freeform/$chatId/history');
    if (response.statusCode == 200) {
      final data = response.data as List<dynamic>;
      return data
          .map((item) => InterviewMessageModel.fromJson(item as Map<String, dynamic>, chatId))
          .toList();
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to fetch freeform history: ${response.statusCode}',
    );
  }

  @override
  Future<List<InterviewSessionModel>> getUserFreeformChats() async {
    final response = await dio.get('/interview/freeform/user/chats');
    if (response.statusCode == 200) {
      final data = response.data as List<dynamic>;
      return data
          .map((item) => InterviewSessionModel.fromFreeformJson(item as Map<String, dynamic>))
          .toList();
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to fetch user freeform chats: ${response.statusCode}',
    );
  }

  @override
  Future<InterviewSessionModel> startStructuredInterview(String field) async {
    final response = await dio.post('/interview/structured/start', data: {
      'field': field,
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      return InterviewSessionModel.fromStructuredJson(
        response.data as Map<String, dynamic>,
        field: field,
      );
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to start structured interview: ${response.statusCode}',
    );
  }

  @override
  Future<InterviewMessageModel> answerStructuredInterview(String chatId, String answer) async {
    final response = await dio.post('/interview/structured/$chatId/answer', data: {
      'answer': answer,
    });
    if (response.statusCode == 200) {
      return InterviewMessageModel.fromJson(response.data as Map<String, dynamic>, chatId);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to submit structured answer: ${response.statusCode}',
    );
  }

  @override
  Future<List<InterviewMessageModel>> getStructuredHistory(String chatId) async {
    final response = await dio.get('/interview/structured/$chatId/history');
    if (response.statusCode == 200) {
      final data = response.data as List<dynamic>;
      return data
          .map((item) => InterviewMessageModel.fromJson(item as Map<String, dynamic>, chatId))
          .toList();
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to fetch structured history: ${response.statusCode}',
    );
  }

  @override
  Future<List<InterviewSessionModel>> getUserStructuredChats() async {
    final response = await dio.get('/interview/structured/user/chats');
    if (response.statusCode == 200) {
      final data = response.data as List<dynamic>;
      return data
          .map((item) {
            final map = item as Map<String, dynamic>;
            final field = map['field'] as String? ?? '';
            return InterviewSessionModel.fromStructuredJson(map, field: field);
          })
          .toList();
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to fetch user structured chats: ${response.statusCode}',
    );
  }
}


