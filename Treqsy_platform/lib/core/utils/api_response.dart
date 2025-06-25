import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:livestream_platform/core/error/failures.dart';

class ApiResponse<T> extends Equatable {
  final bool success;
  final String? message;
  final T? data;
  final List<dynamic>? errors;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? fromJsonT,
  }) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: json['errors'] as List<dynamic>?,
      statusCode: json['statusCode'] as int?,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return <String, dynamic>{
      'success': success,
      'message': message,
      'data': data != null ? toJsonT(data as T) : null,
      'errors': errors,
      'statusCode': statusCode,
    };
  }

  bool get hasData => data != null;
  bool get hasError => !success || errors?.isNotEmpty == true;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;

  Either<Failure, T> toEither() {
    if (success && data != null) {
      return Right(data as T);
    } else if (isUnauthorized) {
      return Left(UnauthorizedFailure(message: message));
    } else if (isForbidden) {
      return Left(ForbiddenFailure(message: message));
    } else if (isNotFound) {
      return Left(NotFoundFailure(message: message));
    } else if (isServerError) {
      return Left(ServerFailure(
        message: message ?? 'Server error',
        statusCode: statusCode,
        data: data,
      ));
    } else if (hasError) {
      return Left(ServerFailure(
        message: message ?? 'Request failed',
        statusCode: statusCode,
        data: errors,
      ));
    } else {
      return Left(UnknownFailure(
        message: message ?? 'Unknown error occurred',
        statusCode: statusCode,
        data: data,
      ));
    }
  }

  @override
  List<Object?> get props => [success, message, data, errors, statusCode];

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, data: $data, errors: $errors, statusCode: $statusCode)';
  }
}
