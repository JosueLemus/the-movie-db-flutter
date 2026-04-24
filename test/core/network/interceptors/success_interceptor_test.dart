import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_movie_db/core/network/interceptors/success_interceptor.dart';
import 'package:the_movie_db/core/services/connectivity_service.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockResponseInterceptorHandler extends Mock
    implements ResponseInterceptorHandler {}

class FakeResponse extends Fake implements Response<dynamic> {}

void main() {
  late MockConnectivityService mockConnectivityService;
  late MockResponseInterceptorHandler mockHandler;
  late SuccessInterceptor interceptor;

  setUpAll(() {
    registerFallbackValue(FakeResponse());
  });

  setUp(() {
    mockConnectivityService = MockConnectivityService();
    mockHandler = MockResponseInterceptorHandler();
    interceptor = SuccessInterceptor(mockConnectivityService);
  });

  group('SuccessInterceptor', () {
    test('calls markOnline on the connectivity service', () {
      final response = Response<dynamic>(
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
      );

      when(() => mockConnectivityService.markOnline()).thenReturn(null);
      when(() => mockHandler.next(any())).thenReturn(null);

      interceptor.onResponse(response, mockHandler);

      verify(() => mockConnectivityService.markOnline()).called(1);
    });

    test('calls handler.next with the response', () {
      final response = Response<dynamic>(
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
      );

      when(() => mockConnectivityService.markOnline()).thenReturn(null);
      when(() => mockHandler.next(any())).thenReturn(null);

      interceptor.onResponse(response, mockHandler);

      verify(() => mockHandler.next(response)).called(1);
    });

    test('markOnline is called before handler.next', () {
      final callOrder = <String>[];
      final response = Response<dynamic>(
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
      );

      when(() => mockConnectivityService.markOnline()).thenAnswer((_) {
        callOrder.add('markOnline');
      });
      when(() => mockHandler.next(any())).thenAnswer((_) {
        callOrder.add('next');
      });

      interceptor.onResponse(response, mockHandler);

      expect(callOrder, equals(['markOnline', 'next']));
    });
  });
}
