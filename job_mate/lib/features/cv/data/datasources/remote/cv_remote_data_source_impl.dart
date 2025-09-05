import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:job_mate/features/cv/data/datasources/remote/cv_remote_data_source.dart';
import 'package:job_mate/features/cv/data/models/cv_details_model.dart';
import 'package:job_mate/features/cv/data/models/cv_feedback_model.dart';
import 'package:job_mate/features/cv/domain/entities/cv_details.dart';
import 'package:job_mate/features/cv/domain/entities/cv_feedback.dart';
import 'package:job_mate/features/cv/domain/entities/suggestion.dart';

class CvRemoteDataSourceImpl extends CvRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource authLocalDataSource;

  CvRemoteDataSourceImpl({required this.dio, required this.authLocalDataSource});

  @override
  Future<CvDetails> uploadCv(String userId, String? rawText, String? filePath) async {
    try {
      final token = await authLocalDataSource.getAccessToken();
      if (token == null) {
        throw ServerFailure('No authentication token available');
      }

      print('Sending uploadCv request to ${dio.options.baseUrl}/cv with userId: $userId, rawText: $rawText, filePath: $filePath, token: $token');

      // Validate input: only one of rawText or filePath is allowed
      if ((rawText == null || rawText.isEmpty) && (filePath == null)) {
        throw ServerFailure('Either rawText or file must be provided');
      }
      if (rawText != null && filePath != null) {
        throw ServerFailure('Cannot provide both rawText and file at the same time');
      }

      // Initial FormData
      var initialFormData = FormData.fromMap({'userId': userId});
      if (rawText != null) {
        initialFormData.fields.add(MapEntry('rawText', rawText));
      } else if (filePath != null) {
        initialFormData.files.add(
          MapEntry(
            'file',
            await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
          ),
        );
      }

      Response? response = await dio.post(
        '/cv',
        data: initialFormData,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'multipart/form-data'},
          receiveTimeout: const Duration(seconds: 30),
          validateStatus: (status) {
            print('uploadCv status: $status');
            return status != null && status < 500; // Allow 307 redirects
          },
          followRedirects: false, // Disable auto-redirect to handle manually
          maxRedirects: 0,
        ),
      );

      print('Received uploadCv response: ${response.statusCode} - ${jsonEncode(response.data)} - Headers: ${response.headers} - Redirected to: ${response.realUri}');

      // Handle redirect manually
      int redirectCount = 0;
      const maxRedirects = 5;
      while (response?.statusCode == 307 && redirectCount < maxRedirects) {
        final location = response?.headers.value('location');
        if (location == null) {
          throw ServerFailure('No Location header in 307 response');
        }

        print('Redirect detected, Location: $location');
        final redirectUrl = location.startsWith('http') ? location : '${dio.options.baseUrl}$location';

        // Create new FormData for each redirect
        var redirectFormData = FormData.fromMap({'userId': userId});
        if (rawText != null) {
          redirectFormData.fields.add(MapEntry('rawText', rawText));
        } else if (filePath != null) {
          redirectFormData.files.add(
            MapEntry(
              'file',
              await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
            ),
          );
        }

        response = await dio.post(
          redirectUrl,
          data: redirectFormData,
          options: Options(
            headers: {'Authorization': 'Bearer $token', 'Content-Type': 'multipart/form-data'},
            receiveTimeout: const Duration(seconds: 30),
            validateStatus: (status) {
              print('Redirected uploadCv status: $status');
              return status != null && status < 500;
            },
          ),
        );

        print('Redirected uploadCv response: ${response.statusCode} - ${jsonEncode(response.data)} - Redirected to: ${response.realUri}');
        redirectCount++;
      }

      if (redirectCount >= maxRedirects) {
        throw ServerFailure('Max redirect limit reached');
      }

      if (response?.data == null || response?.data is! Map<String, dynamic>) {
        throw ServerFailure('Unexpected uploadCv response format: ${jsonEncode(response?.data)}');
      }

      final data = response?.data['data'];
      if (data == null) {
        throw ServerFailure('Data field is missing in response: ${jsonEncode(response?.data)}');
      }

      if (data is Map<String, dynamic>) {
        return CvDetailsModel.fromJson(data);
      } else if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return CvDetailsModel.fromJson(decoded);
          } else {
            throw ServerFailure('Decoded data is not a Map: ${jsonEncode(decoded)}');
          }
        } catch (e) {
          throw ServerFailure('Failed to parse stringified data: $e');
        }
      } else {
        throw ServerFailure('Unexpected data format: ${jsonEncode(data)}');
      }
    } catch (e) {
      print('Error in uploadCv: $e');
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw ServerFailure(e.response?.data['message'] ?? 'Invalid input');
        } else if (e.response?.statusCode == 413) {
          throw ServerFailure('File exceeds max size of 10MB');
        } else if (e.response?.statusCode == 415) {
          throw ServerFailure('Only PDF or DOCX files are allowed');
        }
      }
      throw ServerFailure('Failed to upload CV: $e');
    }
  }

  @override
  Future<CvFeedback> analyzeCv(String cvId) async {
    try {
      final token = await authLocalDataSource.getAccessToken();
      if (token == null) {
        throw ServerFailure('No authentication token available');
      }

      print('Sending analyzeCv request to ${dio.options.baseUrl}/cv/$cvId/analyze with token: $token');
      final response = await dio.post(
        '/cv/$cvId/analyze',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          receiveTimeout: const Duration(seconds: 30),
          validateStatus: (status) {
            print('analyzeCv status: $status');
            return status != null && status < 500;
          },
        ),
      );

      print('Received analyzeCv response: ${response.statusCode} - ${jsonEncode(response.data)} - Headers: ${response.headers}');
      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw ServerFailure('Unexpected analyzeCv response format: ${jsonEncode(response.data)}');
      }

      final data = response.data['data'];
      if (data == null || data['suggestions'] == null) {
        throw ServerFailure('Missing suggestions in response: ${jsonEncode(response.data)}');
      }

      // return CvFeedbackModel.fromJson(data['suggestions']);
       return CvFeedbackModel.fromJson({'data': data});
    } catch (e) {
      print('Error in analyzeCv: $e');
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw ServerFailure('Invalid CV ID');
        } else if (e.response?.statusCode == 404) {
          throw ServerFailure('CV not found');
        }
      }
      throw ServerFailure('Failed to analyze CV: $e');
    }
  }
  // @override
  // Future<Suggestion> getSuggestions() async {
  //   try {
  //     final token = await authLocalDataSource.getAccessToken();
  //     if (token == null) {
  //       throw ServerFailure('No authentication token available');
  //     }

  //     print('Sending getSuggestions request to ${dio.options.baseUrl}/cv/suggestions with token: $token');
  //     final response = await dio.get(
  //       '/cv/suggestions',
  //       options: Options(
  //         headers: {'Authorization': 'Bearer $token'},
  //         receiveTimeout: const Duration(seconds: 30),
  //         validateStatus: (status) {
  //           print('getSuggestions status: $status');
  //           return status != null && status < 500;
  //         },
  //       ),
  //     );

  //     print('Received getSuggestions response: ${response.statusCode} - ${jsonEncode(response.data)} - Headers: ${response.headers}');
  //     if (response.data == null || response.data is! Map<String, dynamic>) {
  //       throw ServerFailure('Unexpected getSuggestions response format: ${jsonEncode(response.data)}');
  //     }

  //     return SuggestionModel.fromJson(response.data);
  //   } catch (e) {
  //     print('Error in getSuggestions: $e');
  //     throw ServerFailure('Failed to get suggestions: $e');
  //   }
  // }
}