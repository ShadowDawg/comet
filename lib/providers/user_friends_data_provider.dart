import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test1/backend/firebase_tools.dart';
import 'package:test1/models/friend_basic_data.dart';
import 'dart:convert';

class FriendsDataProvider extends ChangeNotifier {
  List<FriendBasicData> _friends = [];
  bool _isLoading = false;
  String? _error;

  List<FriendBasicData> get friends => _friends;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFriends(String userUid, List<String> phoneNumbers) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (phoneNumbers.isEmpty) {
        _friends = [];
        _error = null;
      } else {
        // Your existing code to fetch friends
        _friends = await FirebaseGetFriendsBasicDataList(userUid, phoneNumbers);
        await _saveToLocalStorage();
      }
    } catch (e) {
      _error = 'Failed to fetch friends data.';
      print('Error fetching friends data: $e');
      await _loadFromLocalStorage();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshFriends(String userUid, List<String> phoneNumbers) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _friends = await FirebaseGetFriendsBasicDataList(userUid, phoneNumbers);
      await _saveToLocalStorage();
      _error = null;
    } catch (e) {
      _error = 'Failed to refresh friends data.';
      print('Error refreshing friends data: $e');
      // We don't load from local storage here as we want to keep the existing data
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // void addFriend(FriendBasicData friend) {
  //   if (!_friends.any((f) => f.matchUid == friend.matchUid)) {
  //     _friends.add(friend);
  //     _saveToLocalStorage();
  //     notifyListeners();
  //   }
  // }

  // void removeFriend(String matchUid) {
  //   _friends.removeWhere((friend) => friend.matchUid == matchUid);
  //   _saveToLocalStorage();
  //   notifyListeners();
  // }

  // void updateFriend(FriendBasicData updatedFriend) {
  //   final index = _friends
  //       .indexWhere((friend) => friend.matchUid == updatedFriend.matchUid);
  //   if (index != -1) {
  //     _friends[index] = updatedFriend;
  //     _saveToLocalStorage();
  //     notifyListeners();
  //   }
  // }

  Future<void> clearFriends() async {
    _friends = [];
    await _clearLocalStorage();
    notifyListeners();
  }

  Future<void> _saveToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final friendsJson = _friends.map((friend) => friend.toJson()).toList();
    await prefs.setString('friends_data', json.encode(friendsJson));
  }

  Future<void> _loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('friends_data');
    if (storedData != null) {
      final List<dynamic> decodedData = json.decode(storedData);
      _friends = decodedData
          .map((friendJson) => FriendBasicData.fromJson(friendJson))
          .toList();
    }
  }

  Future<void> _clearLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('friends_data');
  }
}
