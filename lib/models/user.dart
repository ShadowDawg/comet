import 'package:cloud_firestore/cloud_firestore.dart';

class userModel {
  final String uid;
  final String email;
  final String name;
  String dateOfBirth;
  String placeOfBirth;
  String photoUrl;
  final String gender;
  final String chatRoomId;
  String handle;
  final int phoneNumber;
  bool notificationsEnabled;
  String? fcmToken;

  userModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.photoUrl,
    required this.gender,
    required this.chatRoomId,
    required this.handle,
    required this.phoneNumber,
    required this.notificationsEnabled,
    this.fcmToken,
  });

  factory userModel.fromJson(Map<String, dynamic> json) {
    return userModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      placeOfBirth: json['placeOfBirth'] ?? '',
      photoUrl: json['photoUrl'] ??
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQWqPhrfTFyCACSkoLLy3NHfEBRNh6xgD-zmw&s',
      gender: json['gender'] ?? '',
      chatRoomId: json['chatRoomId'] ?? '',
      handle: json['handle'] ?? '',
      phoneNumber: json['phoneNumber'] ?? 0,
      notificationsEnabled: json['notificationsEnabled'] ?? false,
      fcmToken: json['fcmToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'dateOfBirth': dateOfBirth,
      'placeOfBirth': placeOfBirth,
      'photoUrl': photoUrl,
      'gender': gender,
      'chatRoomId': chatRoomId,
      'handle': handle,
      'phoneNumber': phoneNumber,
      'notificationsEnabled': notificationsEnabled,
      'fcmToken': fcmToken,
    };
  }

  userModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? dateOfBirth,
    String? placeOfBirth,
    String? photoUrl,
    String? gender,
    String? chatRoomId,
    String? handle,
    int? phoneNumber,
    bool? notificationsEnabled,
    String? fcmToken,
  }) {
    return userModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      photoUrl: photoUrl ?? this.photoUrl,
      gender: gender ?? this.gender,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      handle: handle ?? this.handle,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}

DateTime parseDate(dynamic date) {
  if (date is Timestamp) {
    return date.toDate();
  } else if (date is String) {
    return DateTime.parse(date);
  } else if (date is int) {
    return DateTime.fromMillisecondsSinceEpoch(date);
  } else {
    return DateTime.now();
  }
}
