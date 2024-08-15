import 'package:flutter/foundation.dart';
import 'package:test1/backend/firebase_tools.dart';
import 'package:test1/models/user_and_astro_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserDataProvider extends ChangeNotifier {
  UserAndAstroData? _userData;
  bool _isLoading = false;
  String? _error;

  UserAndAstroData? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUserData(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch data from API using the provided function
      _userData = await backendFirebaseGetUserAndAstroData(userId);

      // Save data to local storage
      await _saveToLocalStorage(_userData!);
    } catch (e) {
      _error = 'Failed to fetch user data. Using cached data if available.';
      print('Error fetching user data: $e');
      // Try to load data from local storage
      _userData = await _loadFromLocalStorage();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setUserData(UserAndAstroData data) {
    _userData = data;
    _saveToLocalStorage(data);
    notifyListeners();
  }

  void updateUserData(UserAndAstroData Function(UserAndAstroData) update) {
    if (_userData != null) {
      _userData = update(_userData!);
      _saveToLocalStorage(_userData!);
      notifyListeners();
    }
  }

  void clearUserData() {
    _userData = null;
    _clearLocalStorage();
    notifyListeners();
  }

  Future<void> _saveToLocalStorage(UserAndAstroData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(data.toJson()));
  }

  Future<UserAndAstroData?> _loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('user_data');
    if (storedData != null) {
      return UserAndAstroData.fromFirestore(json.decode(storedData));
    }
    return null;
  }

  Future<void> _clearLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }
}
