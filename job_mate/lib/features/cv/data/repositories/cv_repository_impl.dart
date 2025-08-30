import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/features/cv/data/datasources/local/profile_local_data_source.dart';
import 'package:job_mate/features/cv/data/datasources/remote/cv_remote_data_source.dart';
import 'package:job_mate/features/cv/domain/entities/cv_details.dart';
import 'package:job_mate/features/cv/domain/entities/cv_feedback.dart';
import 'package:job_mate/features/cv/domain/repositories/cv_repository.dart';

class CvRepositoryImpl implements CvRepository{
  final CvRemoteDataSource remote;
  final ProfileLocalDataSource local;

  CvRepositoryImpl({
    required this.remote,
    required this.local
  });


  @override
  Future<Either<Failure, CvFeedback>> analyzeCv(String cvId) async{
    try{
      final cvFeedback= await remote.analyzeCv(cvId);
      return Right(cvFeedback);
    }catch(e){
      return Left(ServerFailure('Analyze CV failed: $e'));
    }
  }

  @override
  Future<Either<Failure, CvDetails>> uploadCv(String userId, String? rawText, String? filePath) async{
    try{
      final cvDetails= await remote.uploadCv(userId, rawText, filePath);
      final profile= await local.getProfile();
      if(profile!= null){
        await local.saveProfile(profile.copywith(cvId: cvDetails.cvId));
      }
      return Right(cvDetails);

    }catch(e){
      return Left(ServerFailure('Upload CV failed: $e'));
    }
  }}