import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/core/network/network_info.dart';
import 'package:job_mate/features/cv/data/datasources/remote/cv_chat_remote_data_source.dart';

import 'package:job_mate/features/cv/domain/entities/chat_session.dart';
import 'package:job_mate/features/cv/domain/entities/chat_message.dart';
import 'package:job_mate/features/cv/domain/repositories/cv_chat_repository.dart';

class CvChatRepositoryImpl implements CvChatRepository {
  final CvChatRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CvChatRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> createChatSession(String? cvId) async {
    if (await networkInfo.isConnected) {
      try {
        final chatId = await remoteDataSource.createChatSession(cvId);
        return Right(chatId);
      } catch (e) {
        return Left(ServerFailure('Create chat session failed: $e'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendChatMessage(String chatId, String message, String? cvId) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.sendChatMessage(chatId, message, cvId);
        return Right(response);
      } catch (e) {
        return Left(ServerFailure('Send chat message failed: $e'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ChatSession>> getChatHistory(String chatId) async {
    if (await networkInfo.isConnected) {
      try {
        final history = await remoteDataSource.getChatHistory(chatId);
        return Right(history);
      } catch (e) {
        return Left(ServerFailure('Get chat history failed: $e'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<ChatSession>>> getAllChatSessions() async {
    if (await networkInfo.isConnected) {
      try {
        final sessions = await remoteDataSource.getAllChatSessions();
        return Right(sessions);
      } catch (e) {
        return Left(ServerFailure('Get all chat sessions failed: $e'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
}