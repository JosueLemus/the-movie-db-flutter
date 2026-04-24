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

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    final service = sl<ConnectivityService>();
    final connected = await service.isConnected;
    if (mounted) setState(() => _isConnected = connected);
    service.isConnectedStream.listen((connected) {
      if (mounted) setState(() => _isConnected = connected);
    });
  }

  @override
  Widget build(BuildContext context) {
    final offline = _isConnected == false;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: offline ? 36 : 0,
          color: Colors.red[700],
          child: offline
              ? SafeArea(
                  bottom: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'No internet — showing cached content',
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
