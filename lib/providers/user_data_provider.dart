import 'package:flutter/foundation.dart';
import 'package:comet/backend/firebase_tools.dart';
import 'package:comet/models/user.dart';
import 'package:comet/models/user_and_astro_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserDataProvider extends ChangeNotifier {
  UserModel? _userData;
  bool _isLoading = false;
  String? _error;

  UserModel? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUserData(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userData = await backendFirebaseGetUserData(userId);
      await _saveToLocalStorage(_userData!);
    } catch (e) {
      _error = 'Failed to fetch user data.';
      print('Error fetching user data: $e');
      _userData = await _loadFromLocalStorage();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserData() async {
    if (_userData == null) {
      _error = 'No user data available to refresh.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String userId = _userData!.uid;
      UserModel refreshedData = await backendFirebaseGetUserData(userId);

      // Update the current data
      _userData = refreshedData;

      // Save to local storage
      await _saveToLocalStorage(_userData!);

      _error = null;
    } catch (e) {
      _error = 'Failed to refresh user data.';
      print('Error refreshing user data: $e');
      // We don't load from local storage here as we want to keep the existing data
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setUserData(UserModel data) {
    _userData = data;
    _saveToLocalStorage(data);
    notifyListeners();
  }

  void updateUserData(UserModel Function(UserModel) update) {
    if (_userData != null) {
      _userData = update(_userData!);
      _saveToLocalStorage(_userData!);
      notifyListeners();
    }
  }

  Future<void> clearUserData() async {
    _userData = null;
    await _clearLocalStorage();
    notifyListeners();
  }

  Future<void> _saveToLocalStorage(UserModel data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(data.toJson()));
  }

  Future<UserModel?> _loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('user_data');
    if (storedData != null) {
      return UserModel.fromFirestore(json.decode(storedData));
    }
    return null;
  }

  Future<void> _clearLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }
}
