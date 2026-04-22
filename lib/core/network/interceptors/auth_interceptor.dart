import 'package:dio/dio.dart';

// SRP: this interceptor has one job — attach the TMDB API key to every request
class AuthInterceptor extends Interceptor {
  const AuthInterceptor(this._apiKey);

  final String _apiKey;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters['api_key'] = _apiKey;
    handler.next(options);
  }
}
