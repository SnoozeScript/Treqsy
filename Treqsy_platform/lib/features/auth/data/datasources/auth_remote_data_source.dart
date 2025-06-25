import 'package:dartz/dartz.dart';
import 'package:livestream_platform/core/error/failures.dart';
import 'package:livestream_platform/features/auth/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  // Phone authentication
  Future<Either<Failure, String>> sendOtp(String phoneNumber);
  Future<Either<Failure, UserEntity>> verifyOtp({
    required String verificationId,
    required String smsCode,
  });
  
  // Email authentication
  Future<Either<Failure, UserEntity>> loginWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  // Social authentication
  Future<Either<Failure, UserEntity>> loginWithGoogle();
  Future<Either<Failure, UserEntity>> loginWithFacebook();
  Future<Either<Failure, UserEntity>> loginWithApple();
  
  // Account management
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> deleteAccount();
  
  // Session management
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  
  // Password reset
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, void>> confirmPasswordReset({
    required String code,
    required String newPassword,
  });
  
  // User data
  Future<Either<Failure, UserEntity>> updateUserProfile(UserEntity user);
  
  // Token management
  Future<Either<Failure, String?>> getAuthToken();
  Future<Either<Failure, void>> saveAuthToken(String token);
  Future<Either<Failure, void>> deleteAuthToken();
  
  // KYC Verification
  Future<Either<Failure, void>> submitKyc({
    required String documentType,
    required String documentNumber,
    required List<String> documentImages,
  });
  
  // Check KYC status
  Future<Either<Failure, Map<String, dynamic>>> getKycStatus();
}
