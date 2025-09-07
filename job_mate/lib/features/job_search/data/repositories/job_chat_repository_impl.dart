import 'package:dartz/dartz.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/core/network/network_info.dart';
import 'package:job_mate/features/job_search/data/datasource/remote/job_chat_remote_data_source.dart';
import 'package:job_mate/features/job_search/domain/entities/chat.dart';
import 'package:job_mate/features/job_search/domain/repositories/job_chat_repository.dart';

class JobChatRepositoryImpl implements JobChatRepository {
  final JobChatRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  JobChatRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Chat>>> getAllChats() async {
    if (await networkInfo.isConnected) {
      try {
        final chats = await remoteDataSource.getAllChats();
        return Right(chats);
      } catch (e) {
        return Left(ServerFailure('Get all chats failed: $e'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Chat>> getChatById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final chat = await remoteDataSource.getChatById(id);
        return Right(chat);
      } catch (e) {
        return Left(ServerFailure('Get chat by ID failed: $e'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  /// 🔥 Updated: return Map<String, dynamic> instead of Chat
  @override
  Future<Either<Failure, Map<String, dynamic>>> sendChatMessage(
      String message, {String? chatId}) async {
    if (await networkInfo.isConnected) {
      try {
        final response =
            await remoteDataSource.sendChatMessage(message, chatId: chatId);
        return Right(response);
      } catch (e) {
        return Left(ServerFailure('Send chat message failed: $e'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
}
