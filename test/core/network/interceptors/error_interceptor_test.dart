import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/core/network/interceptors/error_interceptor.dart';
import 'package:the_movie_db/core/network/network_exception.dart';

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late ErrorInterceptor interceptor;
  late MockErrorInterceptorHandler mockHandler;

  setUp(() {
    interceptor = const ErrorInterceptor();
    mockHandler = MockErrorInterceptorHandler();
  });

  setUpAll(() {
    registerFallbackValue(
      DioException(
        requestOptions: RequestOptions(),
      ),
    );
  });

  group('ErrorInterceptor', () {
    test('onError calls handler.reject with a DioException', () {
      final requestOptions = RequestOptions(path: '/test');
      final dioError = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionError,
      );

      when(() => mockHandler.reject(any())).thenReturn(null);

      interceptor.onError(dioError, mockHandler);

      final captured = verify(() => mockHandler.reject(captureAny())).captured;
      expect(captured.single, isA<DioException>());
    });

    test('onError wraps error with NetworkException', () {
      final requestOptions = RequestOptions(path: '/test');
      final dioError = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionError,
      );

      DioException? rejectedError;
      when(() => mockHandler.reject(any())).thenAnswer((invocation) {
        rejectedError = invocation.positionalArguments.first as DioException;
      });

      interceptor.onError(dioError, mockHandler);

      expect(rejectedError, isNotNull);
      expect(rejectedError!.error, isA<NetworkException>());
    });

    test('onError maps connectionTimeout DioException to TimeoutException', () {
      final requestOptions = RequestOptions(path: '/test');
      final dioError = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
      );

      DioException? rejectedError;
      when(() => mockHandler.reject(any())).thenAnswer((invocation) {
        rejectedError = invocation.positionalArguments.first as DioException;
      });

      interceptor.onError(dioError, mockHandler);

      expect(rejectedError!.error, isA<TimeoutException>());
    });

    test('onError maps connectionError to NoConnectionException', () {
      final requestOptions = RequestOptions(path: '/test');
      final dioError = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionError,
      );

      DioException? rejectedError;
      when(() => mockHandler.reject(any())).thenAnswer((invocation) {
        rejectedError = invocation.positionalArguments.first as DioException;
      });

      interceptor.onError(dioError, mockHandler);

      expect(rejectedError!.error, isA<NoConnectionException>());
    });

    test('onError maps 401 response to UnauthorizedException', () {
      final requestOptions = RequestOptions(path: '/test');
      final dioError = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: 401,
        ),
      );

      DioException? rejectedError;
      when(() => mockHandler.reject(any())).thenAnswer((invocation) {
        rejectedError = invocation.positionalArguments.first as DioException;
      });

      interceptor.onError(dioError, mockHandler);

      expect(rejectedError!.error, isA<UnauthorizedException>());
    });

    test('onError maps 404 response to NotFoundException', () {
      final requestOptions = RequestOptions(path: '/test');
      final dioError = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: 404,
        ),
      );

      DioException? rejectedError;
      when(() => mockHandler.reject(any())).thenAnswer((invocation) {
        rejectedError = invocation.positionalArguments.first as DioException;
      });

      interceptor.onError(dioError, mockHandler);

      expect(rejectedError!.error, isA<NotFoundException>());
    });

    test('onError maps 500 response to ServerException', () {
      final requestOptions = RequestOptions(path: '/test');
      final dioError = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: 500,
        ),
      );

      DioException? rejectedError;
      when(() => mockHandler.reject(any())).thenAnswer((invocation) {
        rejectedError = invocation.positionalArguments.first as DioException;
      });

      interceptor.onError(dioError, mockHandler);

      expect(rejectedError!.error, isA<ServerException>());
    });

    test('onError preserves original requestOptions', () {
      final requestOptions = RequestOptions(path: '/original/path');
      final dioError = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionError,
      );

      DioException? rejectedError;
      when(() => mockHandler.reject(any())).thenAnswer((invocation) {
        rejectedError = invocation.positionalArguments.first as DioException;
      });

      interceptor.onError(dioError, mockHandler);

      expect(rejectedError!.requestOptions.path, equals('/original/path'));
    });
  });
}
