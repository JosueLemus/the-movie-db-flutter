import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService(this._connectivity) {
    _connectivity.onConnectivityChanged.listen((results) {
      final connected = results.any((r) => r != ConnectivityResult.none);
      if (!_controller.isClosed) _controller.add(connected);
    });
  }

  final Connectivity _connectivity;
  final _controller = StreamController<bool>.broadcast();

  /// Called by the HTTP success interceptor when any request completes.
  void markOnline() {
    if (!_controller.isClosed) _controller.add(true);
  }

  Stream<bool> get isConnectedStream => _controller.stream;

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
