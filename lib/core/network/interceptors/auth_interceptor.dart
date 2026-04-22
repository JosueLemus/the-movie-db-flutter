import 'package:dio/dio.dart';

// SRP: one job — attach TMDB Bearer token to every request
class AuthInterceptor extends Interceptor {
  const AuthInterceptor(this._bearerToken);

  final String _bearerToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer $_bearerToken';
    handler.next(options);
  }
}
