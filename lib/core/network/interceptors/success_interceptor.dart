import 'package:dio/dio.dart';
import 'package:the_movie_db/core/services/connectivity_service.dart';

class SuccessInterceptor extends Interceptor {
  const SuccessInterceptor(this._connectivityService);

  final ConnectivityService _connectivityService;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _connectivityService.markOnline();
    handler.next(response);
  }
}
