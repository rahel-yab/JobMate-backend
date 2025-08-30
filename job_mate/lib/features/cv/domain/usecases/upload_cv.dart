import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/cv/domain/entities/cv_details.dart';
import 'package:job_mate/features/cv/domain/repositories/cv_repository.dart';

class UploadCv {
  final CvRepository repository;

  UploadCv(this.repository);

  Future<Either<Failure,CvDetails>> call(String userId, String? rawText, String? filePath)async{
    if((rawText==null || rawText.isEmpty) && filePath==null){
      return Left(ValidationFailure('Either rawText or file must be provided'));
    }
    if(rawText!=null && filePath != null){
      return Left(ValidationFailure('Cannot provide both rawText and file at the same time'));
    }
    return await repository.uploadCv(userId, rawText, filePath);
  }
}