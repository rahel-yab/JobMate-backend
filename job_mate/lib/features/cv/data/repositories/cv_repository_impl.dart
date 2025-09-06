import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/core/network/network_info.dart';
import 'package:job_mate/features/cv/data/datasources/local/profile_local_data_source.dart';
import 'package:job_mate/features/cv/data/datasources/remote/cv_remote_data_source.dart';
import 'package:job_mate/features/cv/domain/entities/cv_details.dart';
import 'package:job_mate/features/cv/domain/entities/cv_feedback.dart';
import 'package:job_mate/features/cv/domain/entities/suggestion.dart';
import 'package:job_mate/features/cv/domain/repositories/cv_repository.dart';

class CvRepositoryImpl implements CvRepository{
  final CvRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CvRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo
  });


  @override
  Future<Either<Failure, CvFeedback>> analyzeCv(String cvId) async{
    try{
      final cvFeedback= await remoteDataSource.analyzeCv(cvId);
      return Right(cvFeedback);
    }catch(e){
      return Left(ServerFailure('Analyze CV failed: $e'));
    }
  }

  @override
  Future<Either<Failure, CvDetails>> uploadCv(String userId, String? rawText, String? filePath) async{
    try{
      final cvDetails= await remoteDataSource.uploadCv(userId, rawText, filePath);
      final profile= await localDataSource.getProfile();
      if(profile!= null){
        await localDataSource.saveProfile(profile.copywith(cvId: cvDetails.cvId));
      }
      return Right(cvDetails);

    }catch(e){
      return Left(ServerFailure('Upload CV failed: $e'));
    }
  }
  @override
  Future<Either<Failure, Suggestion>> getSuggestions() async {
    if (await networkInfo.isConnected) {
      try {
        final suggestions = await remoteDataSource.getSuggestions();
        return Right(suggestions);
      } catch (e) {
        return Left(ServerFailure('Get suggestions failed: $e'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
}