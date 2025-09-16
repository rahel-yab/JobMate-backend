import 'package:dio/dio.dart';
import 'package:job_mate/features/interview/data/datasources/interview_remote_data_source.dart';
import 'package:job_mate/features/interview/data/models/interview_message_model.dart';
import 'package:job_mate/features/interview/data/models/interview_session_model.dart';

class InterviewRemoteDataSourceImpl implements InterviewRemoteDataSource {
  final Dio dio;

  InterviewRemoteDataSourceImpl({required this.dio});

  @override
  Future<InterviewSessionModel> startFreeformSession(String sessionType) async {
    try {
      print(
        'DEBUG: Sending freeform session request to /interview/freeform/session',
      );
      print('DEBUG: Request data: {"session_type": "$sessionType"}');
      print('DEBUG: Dio headers before request: ${dio.options.headers}');

      final response = await dio.post(
        '/interview/freeform/session',
        data: {'session_type': sessionType},
      );

      print('DEBUG: Freeform session response status: ${response.statusCode}');
      print('DEBUG: Freeform session response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return InterviewSessionModel.fromFreeformJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to start freeform session: ${response.statusCode}',
      );
    } catch (e) {
      print('DEBUG: Freeform session error: $e');
      if (e is DioException) {
        print('DEBUG: DioException response: ${e.response?.data}');
        print('DEBUG: DioException status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  @override
  Future<InterviewMessageModel> sendFreeformMessage(
    String chatId,
    String message,
  ) async {
    try {
      print(
        'DEBUG: Sending freeform message request to /interview/freeform/$chatId/message',
      );
      print('DEBUG: Request data: {"message": "$message"}');
      print('DEBUG: Dio headers before request: ${dio.options.headers}');

      final response = await dio.post(
        '/interview/freeform/$chatId/message',
        data: {'message': message},
      );

      print('DEBUG: Freeform message response status: ${response.statusCode}');
      print('DEBUG: Freeform message response data: ${response.data}');

      if (response.statusCode == 200) {
        return InterviewMessageModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to send freeform message: ${response.statusCode}',
      );
    } catch (e) {
      print('DEBUG: Freeform message error: $e');
      if (e is DioException) {
        print('DEBUG: DioException response: ${e.response?.data}');
        print('DEBUG: DioException status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  @override
  Future<List<InterviewMessageModel>> getFreeformHistory(String chatId) async {
    try {
      print(
        'DEBUG: Sending freeform history request to /interview/freeform/$chatId/history',
      );
      print('DEBUG: Dio headers before request: ${dio.options.headers}');

      final response = await dio.get('/interview/freeform/$chatId/history');

      print('DEBUG: Freeform history response status: ${response.statusCode}');
      print('DEBUG: Freeform history response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>;
        final messages = data['messages'] as List<dynamic>? ?? [];
        return messages
            .map(
              (item) =>
                  InterviewMessageModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to fetch freeform history: ${response.statusCode}',
      );
    } catch (e) {
      print('DEBUG: Freeform history error: $e');
      if (e is DioException) {
        print('DEBUG: DioException response: ${e.response?.data}');
        print('DEBUG: DioException status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  @override
  Future<List<InterviewSessionModel>> getUserFreeformChats() async {
    try {
      print(
        'DEBUG: Sending user freeform chats request to /interview/freeform/user/chats',
      );
      print('DEBUG: Dio headers before request: ${dio.options.headers}');

      final response = await dio.get('/interview/freeform/user/chats');

      print(
        'DEBUG: User freeform chats response status: ${response.statusCode}',
      );
      print('DEBUG: User freeform chats response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as List<dynamic>? ?? [];
        return data
            .map(
              (item) => InterviewSessionModel.fromFreeformJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to fetch user freeform chats: ${response.statusCode}',
      );
    } catch (e) {
      print('DEBUG: User freeform chats error: $e');
      if (e is DioException) {
        print('DEBUG: DioException response: ${e.response?.data}');
        print('DEBUG: DioException status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  // Map display field names to backend field names
  String _mapFieldToBackendFormat(String displayField) {
    switch (displayField.toLowerCase()) {
      case 'software engineer':
      case 'software engineering':
        return 'software_engineering';
      case 'data scientist':
      case 'data science':
        return 'data_scientist';
      case 'product manager':
      case 'product management':
        return 'product_manager';
      case 'marketing':
        return 'marketing';
      case 'sales':
        return 'sales';
      default:
        return 'software_engineering'; // Default fallback
    }
  }

  @override
  Future<InterviewSessionModel> startStructuredInterview(String field) async {
    try {
      final backendField = _mapFieldToBackendFormat(field);
      print(
        'DEBUG: Sending structured interview request to /interview/structured/start',
      );
      print('DEBUG: Display field: "$field" -> Backend field: "$backendField"');
      print(
        'DEBUG: Request data: {"field": "$backendField", "preferred_language": "en"}',
      );
      print('DEBUG: Dio headers before request: ${dio.options.headers}');

      final response = await dio.post(
        '/interview/structured/start',
        data: {
          'field': backendField,
          'preferred_language': 'en', // Add required PreferredLanguage field
        },
      );

      print(
        'DEBUG: Structured interview response status: ${response.statusCode}',
      );
      print('DEBUG: Structured interview response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final sessionModel = InterviewSessionModel.fromStructuredJson(
          response.data as Map<String, dynamic>,
        );

        // Check if response contains the first question and add it to messages
        final firstQuestion = InterviewSessionModel.extractFirstQuestion(
          response.data as Map<String, dynamic>,
        );

        if (firstQuestion != null) {
          print(
            'DEBUG: Found first question in response: ${firstQuestion.content}',
          );
          // Note: Caching will be handled in repository layer
        } else {
          print('DEBUG: No first question found in response');
        }

        return sessionModel;
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to start structured interview: ${response.statusCode}',
      );
    } catch (e) {
      print('DEBUG: Structured interview error: $e');
      if (e is DioException) {
        print('DEBUG: DioException response: ${e.response?.data}');
        print('DEBUG: DioException status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  @override
  Future<InterviewMessageModel> answerStructuredInterview(
    String chatId,
    String answer,
  ) async {
    try {
      print(
        'DEBUG: Sending structured interview answer request to /interview/structured/$chatId/answer',
      );
      print('DEBUG: Request data: {"answer": "$answer"}');
      print('DEBUG: Dio headers before request: ${dio.options.headers}');

      final response = await dio.post(
        '/interview/structured/$chatId/answer',
        data: {'answer': answer},
      );

      print(
        'DEBUG: Structured interview answer response status: ${response.statusCode}',
      );
      print(
        'DEBUG: Structured interview answer response data: ${response.data}',
      );

      if (response.statusCode == 200) {
        final responseMap = response.data as Map<String, dynamic>;
        final data = responseMap['data'] ?? responseMap;
        return InterviewMessageModel.fromStructuredResponse(
          data as Map<String, dynamic>,
        );
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to submit structured answer: ${response.statusCode}',
      );
    } catch (e) {
      print('DEBUG: Structured interview answer error: $e');
      if (e is DioException) {
        print('DEBUG: DioException response: ${e.response?.data}');
        print('DEBUG: DioException status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  @override
  Future<InterviewMessageModel> continueStructuredInterview(
    String chatId,
  ) async {
    try {
      print(
        'DEBUG: Sending continue request to /interview/structured/continue/$chatId',
      );
      print('DEBUG: Dio headers before request: ${dio.options.headers}');

      final response = await dio.get('/interview/structured/continue/$chatId');

      print(
        'DEBUG: Continue structured interview response status: ${response.statusCode}',
      );
      print(
        'DEBUG: Continue structured interview response data: ${response.data}',
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] ?? responseData;

        return InterviewMessageModel.fromStructuredResponse(data);
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message:
            'Failed to continue structured interview: ${response.statusCode}',
      );
    } catch (e) {
      print('DEBUG: Continue structured interview error: $e');
      if (e is DioException) {
        print('DEBUG: DioException response: ${e.response?.data}');
        print('DEBUG: DioException status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  @override
  Future<List<InterviewMessageModel>> getStructuredHistory(
    String chatId,
  ) async {
    try {
      print(
        'DEBUG: Sending structured history request to /interview/structured/$chatId/history',
      );
      print('DEBUG: Dio headers before request: ${dio.options.headers}');

      final response = await dio.get('/interview/structured/$chatId/history');

      print(
        'DEBUG: Structured history response status: ${response.statusCode}',
      );
      print('DEBUG: Structured history response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>;
        final messages = data['messages'] as List<dynamic>? ?? [];
        return messages
            .map(
              (item) =>
                  InterviewMessageModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to fetch structured history: ${response.statusCode}',
      );
    } catch (e) {
      print('DEBUG: Structured history error: $e');
      if (e is DioException) {
        print('DEBUG: DioException response: ${e.response?.data}');
        print('DEBUG: DioException status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  @override
  Future<List<InterviewSessionModel>> getUserStructuredChats() async {
    try {
      print(
        'DEBUG: Sending user structured chats request to /interview/structured/user/chats',
      );
      print('DEBUG: Dio headers before request: ${dio.options.headers}');

      final response = await dio.get('/interview/structured/user/chats');

      print(
        'DEBUG: User structured chats response status: ${response.statusCode}',
      );
      print('DEBUG: User structured chats response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as List<dynamic>? ?? [];
        return data.map((item) {
          final map = item as Map<String, dynamic>;
          return InterviewSessionModel.fromStructuredJson(map);
        }).toList();
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message:
            'Failed to fetch user structured chats: ${response.statusCode}',
      );
    } catch (e) {
      print('DEBUG: User structured chats error: $e');
      if (e is DioException) {
        print('DEBUG: DioException response: ${e.response?.data}');
        print('DEBUG: DioException status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }
}
