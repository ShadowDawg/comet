import '../models/astro_data.dart';
import '../models/user.dart'; // Make sure to import the user model
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/user_and_astro_data.dart'; // For encoding the request body

const apiUrl = 'http://10.0.2.2:8000';

Future<UserAndAstroData> backendFirebaseCreateNewUser(
    Map<String, dynamic> userData) async {
  var url = Uri.parse('$apiUrl/createUser');
  print("calling api to create user");
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      // Parse user data
      userModel user = userModel.fromJson(responseData['userData']);

      // Parse astro data
      AstroDataModel astroData =
          AstroDataModel.fromJson(responseData['astroData']);

      // Return both user and astro data
      return UserAndAstroData(user: user, astroData: astroData);
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error creating user: $e');
  }
}

Future<void> backendFirebaseUpdateMatchApproved(
    String userUid, bool changeTo) async {
  var url = Uri.parse('$apiUrl/updateMatchApproved');
  print(userUid);
  try {
    var response = await http.post(url,
        body: jsonEncode({'userUid': userUid, 'changeTo': changeTo}));
    if (response.statusCode == 200) {
      print("Match approval updated successfully to $changeTo.");
    } else {
      print("Failed to update match approval on server.");
      // Handle errors or retry logic
    }
  } catch (e) {
    print("Error contacting the server: $e");
    // Handle exceptions, possibly network issues or server down
  }
}

Future<UserAndAstroData> backendFirebaseGetUserAndAstroData(String uid) async {
  final response = await http.post(
    Uri.parse('$apiUrl/getUserData'),
    body: json.encode({"userUid": uid}),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return UserAndAstroData(
      user: userModel.fromJson(data['userData']),
      astroData: AstroDataModel.fromJson(data['astroData']),
    );
  } else {
    throw Exception('Failed to load user data');
  }
}

Future<void> backendFirebaseSetUserData(userModel user) async {
  final url = Uri.parse('$apiUrl/setUserData'); // Update with your actual URL

  // Convert DateTime to ISO8601 string
  // final dateOfBirthString = user.dateOfBirth?.toIso8601String();

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'uid': user.uid,
      'email': user.email,
      'name': user.name,
      'dateOfBirth': user.dateOfBirth,
      'placeOfBirth': user.placeOfBirth,
      'photoUrl': user.photoUrl,
      'gender': user.gender,
      'chatRoomId': user.chatRoomId,
      'handle': user.handle,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to set user data');
  }
}

Future<void> backendFirebaseDeleteUserAccount(String uid) async {
  const String url =
      '$apiUrl/deleteUserAccount'; // Replace with your actual API URL

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userUid': uid,
      }),
    );

    if (response.statusCode == 200) {
      // Account deleted successfully
      print('Account deleted successfully');
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to delete account: ${response.body}');
    }
  } catch (e) {
    // Handle any errors that occurred during the HTTP request
    print('Error deleting account: $e');
    throw e; // Re-throw the error so it can be caught by the calling function
  }
}

Future<bool> backendFirebaseUpdateUserNotificationPermission({
  required String userId,
  required String fcmToken,
}) async {
  final url = '$apiUrl/update_user_notification_settings';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // Add any additional headers here, e.g., authorization tokens
      },
      body: json.encode({
        'userId': userId,
        'notificationsEnabled': true,
        'fcmToken': fcmToken,
      }),
    );

    if (response.statusCode == 200) {
      print('Successfully updated notification settings for user: $userId');
      return true;
    } else {
      print('Failed to update notification settings: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error updating notification settings: $e');
    return false;
  }
}

Future<bool> backendFirebaseUpdateUserField(
    String userId, String field, dynamic value) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/updateUserField'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_uid': userId,
        'field': field,
        'value': value,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update $field');
    }
  } catch (e) {
    print('Error updating user field: $e');
    return false;
  }
}
