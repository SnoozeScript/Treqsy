import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  final dynamic data;

  const Failure({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  List<Object?> get props => [message, statusCode, data];

  @override
  String toString() => 'Failure(message: $message, statusCode: $statusCode, data: $data)';
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure({
    String message = 'Server error occurred',
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Cache error occurred',
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'No internet connection',
    int? statusCode = 0,
  }) : super(message: message, statusCode: statusCode);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure({
    String message = 'Validation failed',
    this.errors,
  }) : super(message: message);

  @override
  List<Object?> get props => [...super.props, errors];
}

class AuthFailure extends Failure {
  const AuthFailure({
    String message = 'Authentication failed',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

class PermissionFailure extends Failure {
  final bool isPermanent;

  const PermissionFailure({
    String message = 'Permission required',
    this.isPermanent = false,
  }) : super(message: message);

  @override
  List<Object?> get props => [...super.props, isPermanent];
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    String message = 'Resource not found',
    int? statusCode = 404,
  }) : super(message: message, statusCode: statusCode);
}

class BadRequestFailure extends Failure {
  const BadRequestFailure({
    String message = 'Invalid request',
    int? statusCode = 400,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    String message = 'Unauthorized access',
    int? statusCode = 401,
  }) : super(message: message, statusCode: statusCode);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    String message = 'Access forbidden',
    int? statusCode = 403,
  }) : super(message: message, statusCode: statusCode);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    String message = 'Request timed out',
    int? statusCode = 408,
  }) : super(message: message, statusCode: statusCode);
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    String message = 'Unknown error occurred',
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

// Extension to convert exceptions to failures
extension ExceptionToFailure on Exception {
  Failure toFailure() {
    if (this is ServerException) {
      final e = this as ServerException;
      return ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        data: e.data,
      );
    } else if (this is NetworkException) {
      return const NetworkFailure();
    } else if (this is CacheException) {
      final e = this as CacheException;
      return CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      );
    } else if (this is ValidationException) {
      final e = this as ValidationException;
      return ValidationFailure(
        message: e.message,
        errors: e.errors,
      );
    } else if (this is AuthException) {
      final e = this as AuthException;
      return AuthFailure(
        message: e.message,
        statusCode: e.statusCode,
      );
    } else if (this is PermissionException) {
      final e = this as PermissionException;
      return PermissionFailure(
        message: e.message,
        isPermanent: e.isPermanent,
      );
    } else if (this is NotFoundException) {
      final e = this as NotFoundException;
      return NotFoundFailure(
        message: e.message,
        statusCode: e.statusCode,
      );
    } else if (this is BadRequestException) {
      final e = this as BadRequestException;
      return BadRequestFailure(
        message: e.message,
        statusCode: e.statusCode,
        data: e.data,
      );
    } else if (this is UnauthorizedException) {
      final e = this as UnauthorizedException;
      return UnauthorizedFailure(
        message: e.message,
        statusCode: e.statusCode,
      );
    } else if (this is ForbiddenException) {
      final e = this as ForbiddenException;
      return ForbiddenFailure(
        message: e.message,
        statusCode: e.statusCode,
      );
    } else if (this is RequestCancelledException) {
      return const TimeoutFailure();
    } else {
      return UnknownFailure(
        message: toString(),
      );
    }
  }
}
