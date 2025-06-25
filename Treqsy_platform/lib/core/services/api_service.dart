import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:livestream_platform/core/constants/app_constants.dart';
import 'package:livestream_platform/core/error/exceptions.dart';
import 'package:livestream_platform/core/network/network_info.dart';

class ApiService {
  final Dio _dio;
  final NetworkInfo networkInfo;
  final String baseUrl;

  ApiService({
    required this.networkInfo,
    required this.baseUrl,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            responseType: ResponseType.json,
          ),
        ) {
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          // final token = await _authService.getToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Handle 401 Unauthorized errors
          if (error.response?.statusCode == 401) {
            // await _authService.logout();
            // TODO: Navigate to login
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Generic GET request
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool requiresAuth = true,
  }) async {
    if (!(await networkInfo.isConnected)) {
      throw NetworkException('No internet connection');
    }

    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // Generic POST request
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool requiresAuth = true,
  }) async {
    if (!(await networkInfo.isConnected)) {
      throw NetworkException('No internet connection');
    }

    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          contentType: Headers.jsonContentType,
        ),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // Add other HTTP methods (PUT, DELETE, PATCH) as needed

  // Handle successful responses
  dynamic _handleResponse(Response<dynamic> response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return response.data;
      case 204:
        return null;
      default:
        throw ServerException(
          message: 'Unexpected error occurred',
          statusCode: response.statusCode,
        );
    }
  }

  // Handle Dio errors
  Exception _handleDioError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      final message = data is Map ? data['message'] ?? error.message : error.message;
      final statusCode = error.response?.statusCode;

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return NetworkException('Connection timeout');
        case DioExceptionType.badResponse:
          if (statusCode == 400) {
            return BadRequestException(message: message, statusCode: statusCode);
          } else if (statusCode == 401) {
            return UnauthorizedException(message: message, statusCode: statusCode);
          } else if (statusCode == 403) {
            return ForbiddenException(message: message, statusCode: statusCode);
          } else if (statusCode == 404) {
            return NotFoundException(message: message, statusCode: statusCode);
          } else if (statusCode! >= 500) {
            return ServerException(message: message, statusCode: statusCode);
          }
          break;
        case DioExceptionType.cancel:
          return RequestCancelledException(message: 'Request cancelled');
        case DioExceptionType.unknown:
          if (error.error.toString().contains('SocketException')) {
            return NetworkException('No internet connection');
          }
          break;
        default:
          break;
      }
    }
    return ServerException(message: error.message ?? 'Unexpected error occurred');
  }
}
