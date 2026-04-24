// coverage:ignore-file
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:the_movie_db/core/di/injection_container.dart';
import 'package:the_movie_db/core/services/connectivity_service.dart';

class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({required this.child, super.key});

  final Widget child;

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  // null = unknown (initial), true = online, false = offline
  bool? _isConnected;
  bool _showReconnected = false;
  Timer? _reconnectedTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  @override
  void dispose() {
    _reconnectedTimer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final service = sl<ConnectivityService>();
    final connected = await service.isConnected;
    if (mounted) setState(() => _isConnected = connected);
    service.isConnectedStream.listen((connected) {
      if (!mounted) return;
      final wasOffline = _isConnected == false;
      _reconnectedTimer?.cancel();
      if (wasOffline && connected) {
        setState(() {
          _isConnected = connected;
          _showReconnected = true;
        });
        _reconnectedTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showReconnected = false);
        });
      } else {
        setState(() {
          _isConnected = connected;
          _showReconnected = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final offline = _isConnected == false;
    final showBanner = offline || _showReconnected;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: showBanner ? 36 : 0,
          color: offline ? Colors.red[700] : Colors.green[700],
          child: showBanner
              ? SafeArea(
                  bottom: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        offline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        offline
                            ? 'Sin internet — mostrando contenido guardado'
                            : 'Conexión restaurada',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
