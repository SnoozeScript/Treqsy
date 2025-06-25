import 'package:dartz/dartz.dart';
import 'package:livestream_platform/core/error/failures.dart';
import 'package:livestream_platform/features/auth/domain/entities/user_entity.dart';

abstract class AuthLocalDataSource {
  // User data
  Future<Either<Failure, void>> cacheUser(UserEntity user);
  Future<Either<Failure, UserEntity?>> getLastUser();
  Future<Either<Failure, void>> deleteCachedUser();
  
  // Token management
  Future<Either<Failure, void>> cacheAuthToken(String token);
  Future<Either<Failure, String?>> getCachedAuthToken();
  Future<Either<Failure, void>> deleteCachedAuthToken();
  
  // App settings
  Future<Either<Failure, void>> cacheFirstLaunch(bool isFirstLaunch);
  Future<Either<Failure, bool>> isFirstLaunch();
  
  // Clear all data
  Future<Either<Failure, void>> clearCache();
}
