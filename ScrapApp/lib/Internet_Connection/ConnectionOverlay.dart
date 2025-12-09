import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'ConnectivityService.dart';

class ConnectionOverlay extends StatefulWidget {
  final Widget child;
  const ConnectionOverlay({required this.child, super.key});

  @override
  State<ConnectionOverlay> createState() => _ConnectionOverlayState();
}

class _ConnectionOverlayState extends State<ConnectionOverlay> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(_interceptBackButton);
    ConnectivityService().isConnected.addListener(_handleConnectionChange);
    _isConnected = ConnectivityService().isConnected.value;
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(_interceptBackButton);
    ConnectivityService().isConnected.removeListener(_handleConnectionChange);
    super.dispose();
  }

  void _handleConnectionChange() {
    setState(() {
      _isConnected = ConnectivityService().isConnected.value;
    });

    if (!_isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    }
  }

  bool _interceptBackButton(bool stopDefaultButtonEvent, RouteInfo info) {
    if (!_isConnected) {
      exit(0); // Close app if no internet
      return true; // Prevent default back action
    }
    return false; // Allow default action if connected
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_isConnected)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                    child: Container(color: Colors.black.withOpacity(0.5)),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.cloud_off_rounded, color: Colors.deepOrange, size: 48),
                          SizedBox(height: 12),
                          Text(
                            'No Internet Connection',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please check your network settings.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}



