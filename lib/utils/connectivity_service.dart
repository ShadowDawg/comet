import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  StreamSubscription? _connectivitySubscription;

  ConnectivityService() {
    _initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  bool get isConnected => _isConnected;

  Future<void> _initConnectivity() async {
    try {
      var statuses = await _connectivity.checkConnectivity();
      _updateConnectionStatus(statuses);
    } catch (e) {
      print("Couldn't check connectivity status: $e");
      _isConnected = false;
    }
    notifyListeners();
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _isConnected = results.isNotEmpty &&
        results.any((result) => result != ConnectivityResult.none);
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
