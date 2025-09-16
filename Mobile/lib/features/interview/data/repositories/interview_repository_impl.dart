import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/core/network/network_info.dart';
import 'package:job_mate/features/interview/data/datasources/interview_local_data_source.dart';
import 'package:job_mate/features/interview/data/datasources/interview_remote_data_source.dart';
import 'package:job_mate/features/interview/data/models/interview_message_model.dart';
import 'package:job_mate/features/interview/domain/entities/interview_message.dart';
import 'package:job_mate/features/interview/domain/entities/interview_session.dart';
import 'package:job_mate/features/interview/domain/repositories/interview_repository.dart';

class InterviewRepositoryImpl implements InterviewRepository {
  final InterviewRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final InterviewLocalDataSource localDataSource;

  InterviewRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, InterviewSession>> startFreeformSession(
    String sessionType,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final session = await remoteDataSource.startFreeformSession(sessionType);
      final cached = await localDataSource.getCachedUserFreeformChats();
      await localDataSource.cacheUserFreeformChats([session, ...cached]);
      return Right(session);
    } on DioException catch (e) {
      return Left(_mapDioToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, InterviewMessage>> sendFreeformMessage(
    String chatId,
    String message,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final reply = await remoteDataSource.sendFreeformMessage(chatId, message);
      final cached = await localDataSource.getCachedFreeformHistory(chatId);
      final updated = <InterviewMessageModel>[...cached];
      updated.add(
        InterviewMessageModel(
          chatId: chatId,
          role: 'user',
          content: message,
          timestamp: DateTime.now(),
        ),
      );
      updated.add(reply);
      await localDataSource.cacheFreeformHistory(chatId, updated);
      return Right(reply);
    } on DioException catch (e) {
      return Left(_mapDioToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<InterviewMessage>>> getFreeformHistory(
    String chatId,
  ) async {
    final cached = await localDataSource.getCachedFreeformHistory(chatId);
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteDataSource.getFreeformHistory(chatId);
        await localDataSource.cacheFreeformHistory(chatId, remote);
        return Right(remote);
      } on DioException catch (e) {
        if (cached.isNotEmpty) return Right(cached);
        return Left(_mapDioToFailure(e));
      } catch (e) {
        if (cached.isNotEmpty) return Right(cached);
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    }
    return Right(cached);
  }

  @override
  Future<Either<Failure, List<InterviewSession>>> getUserFreeformChats() async {
    final cached = await localDataSource.getCachedUserFreeformChats();
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteDataSource.getUserFreeformChats();
        await localDataSource.cacheUserFreeformChats(remote);
        return Right(remote);
      } on DioException catch (e) {
        if (cached.isNotEmpty) return Right(cached);
        return Left(_mapDioToFailure(e));
      } catch (e) {
        if (cached.isNotEmpty) return Right(cached);
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    }
    return Right(cached);
  }

  @override
  Future<Either<Failure, InterviewSession>> startStructuredInterview(
    String field,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final session = await remoteDataSource.startStructuredInterview(field);
      final cached = await localDataSource.getCachedUserStructuredChats();
      await localDataSource.cacheUserStructuredChats([session, ...cached]);
      return Right(session);
    } on DioException catch (e) {
      return Left(_mapDioToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, InterviewMessage>> answerStructuredInterview(
    String chatId,
    String answer,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final reply = await remoteDataSource.answerStructuredInterview(
        chatId,
        answer,
      );
      final cached = await localDataSource.getCachedStructuredHistory(chatId);
      final updated = <InterviewMessageModel>[...cached];
      updated.add(
        InterviewMessageModel(
          chatId: chatId,
          role: 'user',
          content: answer,
          timestamp: DateTime.now(),
        ),
      );
      updated.add(reply);
      await localDataSource.cacheStructuredHistory(chatId, updated);
      return Right(reply);
    } on DioException catch (e) {
      return Left(_mapDioToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<InterviewMessage>>> getStructuredHistory(
    String chatId,
  ) async {
    final cached = await localDataSource.getCachedStructuredHistory(chatId);
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteDataSource.getStructuredHistory(chatId);
        await localDataSource.cacheStructuredHistory(chatId, remote);
        return Right(remote);
      } on DioException catch (e) {
        if (cached.isNotEmpty) return Right(cached);
        return Left(_mapDioToFailure(e));
      } catch (e) {
        if (cached.isNotEmpty) return Right(cached);
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    }
    return Right(cached);
  }

  @override
  Future<Either<Failure, List<InterviewSession>>>
  getUserStructuredChats() async {
    final cached = await localDataSource.getCachedUserStructuredChats();
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteDataSource.getUserStructuredChats();
        await localDataSource.cacheUserStructuredChats(remote);
        return Right(remote);
      } on DioException catch (e) {
        if (cached.isNotEmpty) return Right(cached);
        return Left(_mapDioToFailure(e));
      } catch (e) {
        if (cached.isNotEmpty) return Right(cached);
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    }
    return Right(cached);
  }

  @override
  Future<Either<Failure, InterviewMessage>> continueStructuredInterview(
    String chatId,
  ) async {
    try {
      final result = await remoteDataSource.continueStructuredInterview(chatId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _mapDioToFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final message = e.message ?? 'Server error';
        switch (status) {
          case 400:
            return ServerFailure('Bad request: $message');
          case 401:
            return ServerFailure('Unauthorized: $message');
          case 403:
            return ServerFailure('Forbidden: $message');
          case 404:
            return ServerFailure('Not found: $message');
          case 500:
            return ServerFailure('Internal server error: $message');
          default:
            return ServerFailure('Server error ($status): $message');
        }
      case DioExceptionType.cancel:
        return const ServerFailure('Request was cancelled');
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'Connection error. Please check your internet connection.',
        );
      case DioExceptionType.badCertificate:
        return const ServerFailure('Certificate error');
      case DioExceptionType.unknown:
        return ServerFailure('Unknown error: ${e.message}');
    }
  }
}
