import 'package:job_mate/features/cv/domain/entities/cv_details.dart';

class CvDetailsModel extends CvDetails{
  const CvDetailsModel({
    required super.cvId, 
    required super.userId, 
    String? fileName,
    required super.createdAt});

    factory CvDetailsModel.fromJson(Map<String, dynamic> json){
      return CvDetailsModel(
        cvId: json['cvId'] as String, 
        userId: json['userId'] as String,
        fileName: json['fileName'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String));
    }
    Map<String,dynamic> toJson(){
      return{
        'cvId': cvId,
        'userId': userId,
        'fileName': fileName,
        'createdAt': createdAt.toIso8601String(),
      };
    }
  
}