import 'package:dio/dio.dart';

sealed class NetworkException implements Exception {
  const NetworkException(this.message);

  factory NetworkException.fromDioException(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout => const TimeoutException(),
      DioExceptionType.connectionError => const NoConnectionException(),
      _ => switch (e.response?.statusCode) {
        401 => const UnauthorizedException(),
        404 => const NotFoundException(),
        500 => const ServerException(),
        _ => UnknownException(e.message ?? 'Unknown error'),
      },
    };
  }

  final String message;
}

final class TimeoutException extends NetworkException {
  const TimeoutException() : super('Request timed out');
}

final class NoConnectionException extends NetworkException {
  const NoConnectionException() : super('No internet connection');
}

final class UnauthorizedException extends NetworkException {
  const UnauthorizedException() : super('Invalid API key');
}

final class NotFoundException extends NetworkException {
  const NotFoundException() : super('Resource not found');
}

final class ServerException extends NetworkException {
  const ServerException() : super('Server error');
}

final class UnknownException extends NetworkException {
  const UnknownException(super.message);
}
