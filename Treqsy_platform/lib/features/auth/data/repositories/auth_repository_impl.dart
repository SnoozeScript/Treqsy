import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:livestream_platform/core/error/exceptions.dart';
import 'package:livestream_platform/core/error/failures.dart';
import 'package:livestream_platform/core/network/network_info.dart';
import 'package:livestream_platform/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:livestream_platform/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:livestream_platform/features/auth/domain/entities/user_entity.dart';
import 'package:livestream_platform/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  @override
  Future<Either<Failure, String>> sendOtp(String phoneNumber) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      // Format phone number if needed
      final formattedPhoneNumber = phoneNumber.startsWith('+')
          ? phoneNumber
          : '+91$phoneNumber'; // Default to India country code

      // Send verification code to the phone number
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-retrieval or instant verification
          // This will be handled automatically
        },
        verificationFailed: (FirebaseAuthException e) {
          throw AuthException(
            message: _getFirebaseAuthErrorMessage(e),
            statusCode: 400,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          // Verification code sent successfully
          // We'll handle the verification in verifyOtp method
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-resolution timeout
          // You can handle this case if needed
        },
        timeout: const Duration(seconds: 60),
      );

      // In a real app, you would return the verificationId from the codeSent callback
      // For this example, we'll return a placeholder
      return const Right('verification_id_placeholder');
    } on AuthException catch (e) {
      return Left(e.toFailure() as AuthFailure);
    } on FirebaseAuthException catch (e) {
      return Left(
        AuthFailure(
          message: _getFirebaseAuthErrorMessage(e),
          statusCode: 400,
        ),
      );
    } catch (e) {
      return Left(
        AuthFailure(
          message: e.toString(),
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      // Create a PhoneAuthCredential with the code
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in the user with the credential
      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return Left(
          AuthFailure(message: 'Authentication failed. Please try again.'),
        );
      }

      // Check if user exists in your backend
      final user = await _getOrCreateUser(firebaseUser);
      
      // Save user data locally
      await localDataSource.cacheUser(user);
      
      // Save auth token if available
      final token = await firebaseUser.getIdToken();
      if (token != null) {
        await localDataSource.cacheAuthToken(token);
      }

      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(
        AuthFailure(
          message: _getFirebaseAuthErrorMessage(e),
          statusCode: 400,
        ),
      );
    } catch (e) {
      return Left(
        AuthFailure(
          message: e.toString(),
          statusCode: 500,
        ),
      );
    }
  }

  // Helper method to get or create user in your backend
  Future<UserEntity> _getOrCreateUser(User firebaseUser) async {
    try {
      // Try to get user from your backend
      // final response = await apiService.get('/users/${firebaseUser.uid}');
      // if (response != null) {
      //   return UserModel.fromJson(response.data);
      // }
      
      // If user doesn't exist, create a new one
      final newUser = UserEntity(
        id: firebaseUser.uid,
        email: firebaseUser.email,
        phoneNumber: firebaseUser.phoneNumber,
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        isEmailVerified: firebaseUser.emailVerified,
        isPhoneVerified: firebaseUser.phoneNumber != null,
        createdAt: DateTime.now(),
      );
      
      // Save to your backend
      // await apiService.post('/users', data: newUser.toJson());
      
      return newUser;
    } catch (e) {
      // If there's an error with the backend, return a basic user from Firebase
      return UserEntity(
        id: firebaseUser.uid,
        email: firebaseUser.email,
        phoneNumber: firebaseUser.phoneNumber,
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        isEmailVerified: firebaseUser.emailVerified,
        isPhoneVerified: firebaseUser.phoneNumber != null,
        createdAt: DateTime.now(),
      );
    }
  }

  // Helper method to get user-friendly error messages from Firebase Auth
  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-verification-code':
        return 'The verification code is invalid. Please try again.';
      case 'invalid-phone-number':
        return 'The provided phone number is not valid.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'session-expired':
        return 'The SMS code has expired. Please request a new one.';
      case 'quota-exceeded':
        return 'Quota exceeded. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this phone number. Please sign up first.';
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled. Please contact support.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }

  // Implement other methods from AuthRepository interface
  @override
  Future<Either<Failure, UserEntity>> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Implementation
    return Left(UnimplementedFailure());
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    // Implementation
    return Left(UnimplementedFailure());
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithFacebook() async {
    // Implementation
    return Left(UnimplementedFailure());
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithApple() async {
    // Implementation
    return Left(UnimplementedFailure());
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await firebaseAuth.signOut();
      await googleSignIn.signOut();
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(
        AuthFailure(message: 'Failed to sign out. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
        await localDataSource.clearCache();
        return const Right(null);
      }
      return const Left(NotFoundFailure(message: 'No user found'));
    } catch (e) {
      return Left(
        AuthFailure(message: 'Failed to delete account. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final localUser = await localDataSource.getLastUser();
      if (localUser != null) {
        return Right(localUser);
      }
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to get current user from cache'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null) {
        // Check if token is still valid
        final tokenResult = await user.getIdTokenResult(true);
        return Right(!tokenResult.token.isNullOrEmpty);
      }
      return const Right(false);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(
        AuthFailure(
          message: _getFirebaseAuthErrorMessage(e),
          statusCode: 400,
        ),
      );
    } catch (e) {
      return Left(
        AuthFailure(message: 'Failed to send password reset email'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      await firebaseAuth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(
        AuthFailure(
          message: _getFirebaseAuthErrorMessage(e),
          statusCode: 400,
        ),
      );
    } catch (e) {
      return Left(
        AuthFailure(message: 'Failed to reset password'),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile(UserEntity user) async {
    try {
      await localDataSource.cacheUser(user);
      return Right(user);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to update user profile'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> getAuthToken() async {
    try {
      final token = await localDataSource.getCachedAuthToken();
      if (token != null) {
        return Right(token);
      }
      return const Left(NotFoundFailure(message: 'No auth token found'));
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to get auth token'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveAuthToken(String token) async {
    try {
      await localDataSource.cacheAuthToken(token);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to save auth token'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteAuthToken() async {
    try {
      await localDataSource.deleteCachedAuthToken();
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to delete auth token'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> submitKyc({
    required String documentType,
    required String documentNumber,
    required List<String> documentImages,
  }) async {
    // Implementation
    return Left(UnimplementedFailure());
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getKycStatus() async {
    // Implementation
    return Left(UnimplementedFailure());
  }
}

// Helper extension for null safety
extension StringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

// Helper class for unimplemented features
class UnimplementedFailure extends Failure {
  const UnimplementedFailure({
    String message = 'This feature is not implemented yet',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}
