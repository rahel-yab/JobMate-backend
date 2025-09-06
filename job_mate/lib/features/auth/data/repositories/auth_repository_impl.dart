import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:job_mate/core/error/failure.dart';
import 'package:job_mate/core/network/network_info.dart';
import 'package:job_mate/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:job_mate/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:job_mate/features/auth/data/models/auth_token_model.dart';
import 'package:job_mate/features/auth/data/models/user_model.dart';
import 'package:job_mate/features/auth/domain/entities/auth_token.dart';
import 'package:job_mate/features/auth/domain/entities/user.dart';
import 'package:job_mate/features/auth/domain/repositories/auth_repository.dart';

/// Concrete implementation of AuthRepository

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AuthToken>> refreshToken() async {
    if (await networkInfo.isConnected) {
      try {
        final authTokenModel = await remoteDataSource.refreshToken();
        await localDataSource.cacheAuthToken(authTokenModel);
        return Right(authTokenModel);
      } on DioException catch (e) {
        return Left(_handleDioException(e));
      } catch (e) {
        return Left(ServerFailure('Unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.login(email, password);
        final userModel = response['user'] as UserModel;
        final authTokenModel = response['authToken'] as AuthTokenModel;

        // Cache the user
        await localDataSource.cacheUser(userModel);
        // Cache the auth token
        await localDataSource.cacheAuthToken(authTokenModel);
        return Right(userModel); // Return the user as per the interface
      } on DioException catch (e) {
        return Left(_handleDioException(e));
      } catch (e) {
        return Left(ServerFailure('Unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, User>> register(String email, String password, String otp) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.register(email, password, otp);
        await localDataSource.cacheUser(userModel);
        return Right(userModel);
      } on DioException catch (e) {
        return Left(_handleDioException(e));
      } catch (e) {
        return Left(ServerFailure('Unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.logout();
        await localDataSource.clearAuthData();
        return const Right(null);
      } on DioException catch (e) {
        // Even if remote logout fails, clear local data
        await localDataSource.clearAuthData();
        return Left(_handleDioException(e));
      } catch (e) {
        // Even if remote logout fails, clear local data
        await localDataSource.clearAuthData();
        return Left(ServerFailure('Unexpected error occurred: ${e.toString()}'));
      }
    } else {
      // If no internet, just clear local data
      await localDataSource.clearAuthData();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> requestOtp(String email) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.requestOtp(email);
        return const Right(null);
      } on DioException catch (e) {
        return Left(_handleDioException(e));
      } catch (e) {
        return Left(ServerFailure('Unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  /// Handle DioException and convert to appropriate Failure
  Failure _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure('Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.message ?? 'Server error occurred';
        
        switch (statusCode) {
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
            return ServerFailure('Server error ($statusCode): $message');
        }
      
      case DioExceptionType.cancel:
        return ServerFailure('Request was cancelled');
      
      case DioExceptionType.connectionError:
        return NetworkFailure('Connection error. Please check your internet connection.');
      
      case DioExceptionType.badCertificate:
        return ServerFailure('Certificate error');
      
      case DioExceptionType.unknown:
        return ServerFailure('Unknown error occurred: ${e.message}');
    }
  }
  @override
  Future<Either<Failure, User>> googleLogin(String token) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.googleLogin(token);
        final userModel = response['user'] as UserModel;
        final authTokenModel = response['authToken'] as AuthTokenModel;

        await localDataSource.cacheUser(userModel);
        await localDataSource.cacheAuthToken(authTokenModel);
        return Right(userModel);
      } on DioException catch (e) {
        return Left(_handleDioException(e));
      } catch (e) {
        return Left(ServerFailure('Unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
}
