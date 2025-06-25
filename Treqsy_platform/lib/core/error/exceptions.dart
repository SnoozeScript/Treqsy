// Base exception class
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  AppException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

// Network related exceptions
class NetworkException extends AppException {
  NetworkException({String? message})
      : super(
          message: message ?? 'No internet connection',
          statusCode: 0,
        );
}

// Server related exceptions
class ServerException extends AppException {
  ServerException({
    String? message,
    int? statusCode,
    dynamic data,
  }) : super(
          message: message ?? 'Server error occurred',
          statusCode: statusCode ?? 500,
          data: data,
        );
}

// 400 Bad Request
class BadRequestException extends ServerException {
  BadRequestException({
    String? message,
    int? statusCode,
    dynamic data,
  }) : super(
          message: message ?? 'Invalid request',
          statusCode: statusCode ?? 400,
          data: data,
        );
}

// 401 Unauthorized
class UnauthorizedException extends ServerException {
  UnauthorizedException({
    String? message,
    int? statusCode,
    dynamic data,
  }) : super(
          message: message ?? 'Unauthorized access',
          statusCode: statusCode ?? 401,
          data: data,
        );
}

// 403 Forbidden
class ForbiddenException extends ServerException {
  ForbiddenException({
    String? message,
    int? statusCode,
    dynamic data,
  }) : super(
          message: message ?? 'Access forbidden',
          statusCode: statusCode ?? 403,
          data: data,
        );
}

// 404 Not Found
class NotFoundException extends ServerException {
  NotFoundException({
    String? message,
    int? statusCode,
    dynamic data,
  }) : super(
          message: message ?? 'Resource not found',
          statusCode: statusCode ?? 404,
          data: data,
        );
}

// Request cancelled
class RequestCancelledException extends AppException {
  RequestCancelledException({String? message})
      : super(
          message: message ?? 'Request cancelled',
          statusCode: -1,
        );
}

// Cache related exceptions
class CacheException implements Exception {
  final String message;
  final int? statusCode;

  CacheException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}

// Local storage exceptions
class LocalStorageException implements Exception {
  final String message;
  final int? statusCode;

  LocalStorageException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}

// Validation exceptions
class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? errors;

  ValidationException({
    required this.message,
    this.errors,
  });

  @override
  String toString() => message;
}

// Auth exceptions
class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}

// Permission exceptions
class PermissionException implements Exception {
  final String message;
  final bool isPermanent;

  PermissionException({
    required this.message,
    this.isPermanent = false,
  });

  @override
  String toString() => message;
}
