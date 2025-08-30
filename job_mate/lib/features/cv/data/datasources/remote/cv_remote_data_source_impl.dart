import 'package:dio/dio.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/cv/data/datasources/remote/cv_remote_data_source.dart';
import 'package:job_mate/features/cv/data/models/cv_details_model.dart';
import 'package:job_mate/features/cv/data/models/cv_feedback_model.dart';
import 'package:job_mate/features/cv/domain/entities/cv_details.dart';
import 'package:job_mate/features/cv/domain/entities/cv_feedback.dart';

class CvRemoteDataSourceImpl extends CvRemoteDataSource{
  final Dio _dio=Dio();
  final String baseUrl='http://localhost:8080';
  
  @override
  Future<CvFeedback> analyzeCv(String cvId)async {
    try{
      final response= await _dio.post('$baseUrl/cv/$cvId/analyze');
      return CvFeedbackModel.fromJson(response.data);
    }catch(e){
      throw ServerFailure('Failed to analyze CV: $e');
    }
    
  }

  @override
  Future<CvDetails> uploadCv(String userId, String? rawText, String? filePath) async{
    try{
      final formData=FormData.fromMap({
        'userId': userId,
        if (rawText != null) 'rawText': rawText,
        if (filePath != null) 'file': await MultipartFile.fromFile(filePath, filename: 'resume.pdf')
      });
      final response = await _dio.post(
        '$baseUrl/cv',
        data: formData);

      return CvDetailsModel.fromJson(response.data['details']);

    }catch(e){
      throw ServerFailure('Failed to upload CV: $e');
    }
   
  }
  
}