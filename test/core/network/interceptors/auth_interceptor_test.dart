import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/core/network/interceptors/auth_interceptor.dart';

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  late AuthInterceptor interceptor;
  late MockRequestInterceptorHandler mockHandler;

  const testToken = 'test_bearer_token_12345';

  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
  });

  setUp(() {
    interceptor = const AuthInterceptor(testToken);
    mockHandler = MockRequestInterceptorHandler();
  });

  group('AuthInterceptor', () {
    test('onRequest adds Authorization Bearer header', () {
      final options = RequestOptions(path: '/test');

      when(() => mockHandler.next(any())).thenReturn(null);

      interceptor.onRequest(options, mockHandler);

      expect(
        options.headers['Authorization'],
        equals('Bearer $testToken'),
      );
    });

    test('onRequest calls handler.next with modified options', () {
      final options = RequestOptions(path: '/test');

      when(() => mockHandler.next(options)).thenReturn(null);

      interceptor.onRequest(options, mockHandler);

      verify(() => mockHandler.next(options)).called(1);
    });

    test('onRequest uses the provided bearer token', () {
      const differentToken = 'another_token_xyz';
      const anotherInterceptor = AuthInterceptor(differentToken);
      final options = RequestOptions(path: '/movies');

      when(() => mockHandler.next(any())).thenReturn(null);

      anotherInterceptor.onRequest(options, mockHandler);

      expect(
        options.headers['Authorization'],
        equals('Bearer $differentToken'),
      );
    });
  });
}
