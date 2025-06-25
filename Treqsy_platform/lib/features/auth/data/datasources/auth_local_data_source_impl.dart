import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:livestream_platform/core/error/exceptions.dart';
import 'package:livestream_platform/core/error/failures.dart';
import 'package:livestream_platform/features/auth/data/models/user_model.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _userKey = 'cached_user';
  static const String _authTokenKey = 'auth_token';
  static const String _firstLaunchKey = 'first_launch';
  
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;
  
  AuthLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, void>> cacheUser(UserModel user) async {
    try {
      final userJson = user.toJson();
      final userString = jsonEncode(userJson);
      
      await sharedPreferences.setString(_userKey, userString);
      return const Right(null);
    } catch (e) {
      return Left(CacheException(message: 'Failed to cache user'));
    }
  }

  @override
  Future<Either<Failure, UserModel?>> getLastUser() async {
    try {
      final userString = sharedPreferences.getString(_userKey);
      if (userString != null) {
        final userJson = jsonDecode(userString) as Map<String, dynamic>;
        return Right(UserModel.fromJson(userJson));
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheException(message: 'Failed to get cached user'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCachedUser() async {
    try {
      await sharedPreferences.remove(_userKey);
      return const Right(null);
    } catch (e) {
      return Left(CacheException(message: 'Failed to delete cached user'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheAuthToken(String token) async {
    try {
      await secureStorage.write(key: _authTokenKey, value: token);
      return const Right(null);
    } catch (e) {
      return Left(CacheException(message: 'Failed to cache auth token'));
    }
  }

  @override
  Future<Either<Failure, String?>> getCachedAuthToken() async {
    try {
      final token = await secureStorage.read(key: _authTokenKey);
      return Right(token);
    } catch (e) {
      return Left(CacheException(message: 'Failed to get cached auth token'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCachedAuthToken() async {
    try {
      await secureStorage.delete(key: _authTokenKey);
      return const Right(null);
    } catch (e) {
      return Left(CacheException(message: 'Failed to delete cached auth token'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheFirstLaunch(bool isFirstLaunch) async {
    try {
      await sharedPreferences.setBool(_firstLaunchKey, isFirstLaunch);
      return const Right(null);
    } catch (e) {
      return Left(CacheException(message: 'Failed to cache first launch'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFirstLaunch() async {
    try {
      final isFirstLaunch = sharedPreferences.getBool(_firstLaunchKey) ?? true;
      return Right(isFirstLaunch);
    } catch (e) {
      return Left(CacheException(message: 'Failed to get first launch status'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      // Clear all data from shared preferences
      await sharedPreferences.clear();
      
      // Clear all data from secure storage
      await secureStorage.deleteAll();
      
      return const Right(null);
    } catch (e) {
      return Left(CacheException(message: 'Failed to clear cache'));
    }
  }
}
