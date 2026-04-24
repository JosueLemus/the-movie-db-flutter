import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:the_movie_db/core/env/app_flavor.dart';
import 'package:the_movie_db/core/network/interceptors/auth_interceptor.dart';
import 'package:the_movie_db/core/network/interceptors/error_interceptor.dart';
import 'package:the_movie_db/core/network/interceptors/success_interceptor.dart';
import 'package:the_movie_db/core/services/connectivity_service.dart';

// DIP: callers depend on this abstraction, not on Dio directly
Dio createDioClient(String apiKey, ConnectivityService connectivityService) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.tmdbBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
      queryParameters: {'language': 'es-AR'},
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(apiKey),
    const ErrorInterceptor(),
    SuccessInterceptor(connectivityService),
    if (AppConfig.isDevelopment)
      PrettyDioLogger(requestBody: true, responseBody: false),
  ]);

  return dio;
}
