import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_movie_db/core/network/network_exception.dart';

DioException _makeDioException({
  DioExceptionType type = DioExceptionType.unknown,
  int? statusCode,
  String? message,
}) {
  return DioException(
    requestOptions: RequestOptions(path: '/test'),
    type: type,
    response: statusCode != null
        ? Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: statusCode,
          )
        : null,
    message: message,
  );
}

void main() {
  group('NetworkException.fromDioException', () {
    test('connectionTimeout maps to TimeoutException', () {
      final e = _makeDioException(type: DioExceptionType.connectionTimeout);
      final result = NetworkException.fromDioException(e);
      expect(result, isA<TimeoutException>());
      expect(result.message, equals('Request timed out'));
    });

    test('receiveTimeout maps to TimeoutException', () {
      final e = _makeDioException(type: DioExceptionType.receiveTimeout);
      final result = NetworkException.fromDioException(e);
      expect(result, isA<TimeoutException>());
    });

    test('sendTimeout maps to TimeoutException', () {
      final e = _makeDioException(type: DioExceptionType.sendTimeout);
      final result = NetworkException.fromDioException(e);
      expect(result, isA<TimeoutException>());
    });

    test('connectionError maps to NoConnectionException', () {
      final e = _makeDioException(type: DioExceptionType.connectionError);
      final result = NetworkException.fromDioException(e);
      expect(result, isA<NoConnectionException>());
      expect(result.message, equals('No internet connection'));
    });

    test('401 status maps to UnauthorizedException', () {
      final e = _makeDioException(statusCode: 401);
      final result = NetworkException.fromDioException(e);
      expect(result, isA<UnauthorizedException>());
      expect(result.message, equals('Invalid API key'));
    });

    test('404 status maps to NotFoundException', () {
      final e = _makeDioException(statusCode: 404);
      final result = NetworkException.fromDioException(e);
      expect(result, isA<NotFoundException>());
      expect(result.message, equals('Resource not found'));
    });

    test('500 status maps to ServerException', () {
      final e = _makeDioException(statusCode: 500);
      final result = NetworkException.fromDioException(e);
      expect(result, isA<ServerException>());
      expect(result.message, equals('Server error'));
    });

    test(
      'unknown status with message maps to UnknownException with message',
      () {
        final e = _makeDioException(
          statusCode: 503,
          message: 'Service unavailable',
        );
        final result = NetworkException.fromDioException(e);
        expect(result, isA<UnknownException>());
        expect(result.message, equals('Service unavailable'));
      },
    );

    test(
      'unknown type without response maps to UnknownException with fallback',
      () {
        final e = _makeDioException();
        final result = NetworkException.fromDioException(e);
        expect(result, isA<UnknownException>());
        expect(result.message, equals('Unknown error'));
      },
    );

    test('unknown type without response uses provided message', () {
      final e = _makeDioException(
        message: 'Custom error',
      );
      final result = NetworkException.fromDioException(e);
      expect(result, isA<UnknownException>());
      expect(result.message, equals('Custom error'));
    });
  });

  group('NetworkException subclasses', () {
    test('TimeoutException implements Exception', () {
      expect(const TimeoutException(), isA<Exception>());
    });

    test('NoConnectionException implements Exception', () {
      expect(const NoConnectionException(), isA<Exception>());
    });

    test('UnauthorizedException implements Exception', () {
      expect(const UnauthorizedException(), isA<Exception>());
    });

    test('NotFoundException implements Exception', () {
      expect(const NotFoundException(), isA<Exception>());
    });

    test('ServerException implements Exception', () {
      expect(const ServerException(), isA<Exception>());
    });

    test('UnknownException implements Exception', () {
      expect(const UnknownException('error'), isA<Exception>());
    });

    test('UnknownException stores custom message', () {
      const e = UnknownException('Custom failure');
      expect(e.message, equals('Custom failure'));
    });

    test('all exceptions extend NetworkException', () {
      expect(const TimeoutException(), isA<NetworkException>());
      expect(const NoConnectionException(), isA<NetworkException>());
      expect(const UnauthorizedException(), isA<NetworkException>());
      expect(const NotFoundException(), isA<NetworkException>());
      expect(const ServerException(), isA<NetworkException>());
      expect(const UnknownException('e'), isA<NetworkException>());
    });
  });
}
