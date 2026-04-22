import 'package:dio/dio.dart';
import 'package:the_movie_db/core/network/network_exception.dart';

// SRP: converts raw Dio errors into domain-level NetworkException
class ErrorInterceptor extends Interceptor {
  const ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: NetworkException.fromDioException(err),
        type: err.type,
        response: err.response,
      ),
    );
  }
}
