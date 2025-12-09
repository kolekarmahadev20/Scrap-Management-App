import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/foundation.dart'; // ✅ Needed for ValueNotifier

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  ConnectivityService._internal();

  final ValueNotifier<bool> _isConnected = ValueNotifier(true);

  ValueNotifier<bool> get isConnected => _isConnected;

  void initialize() {
    _checkConnection();

    Connectivity().onConnectivityChanged.listen((_) => _checkConnection());

    InternetConnectionChecker().onStatusChange.listen((status) {
      _isConnected.value = status == InternetConnectionStatus.connected;
    });
  }

  Future<void> _checkConnection() async {
    _isConnected.value = await InternetConnectionChecker().hasConnection;
  }
}
