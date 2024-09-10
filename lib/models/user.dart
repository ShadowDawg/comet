import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comet/models/astro_data.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  String dateOfBirth;
  String placeOfBirth;
  String photoUrl;
  final String gender;

  String handle;
  final String phoneNumber;
  bool notificationsEnabled;
  String? fcmToken;
  final AstroDataModel astroData;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.photoUrl,
    required this.gender,
    required this.handle,
    required this.phoneNumber,
    required this.notificationsEnabled,
    this.fcmToken,
    required this.astroData,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      placeOfBirth: json['placeOfBirth'] ?? '',
      photoUrl: json['photoUrl'] ??
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQWqPhrfTFyCACSkoLLy3NHfEBRNh6xgD-zmw&s',
      gender: json['gender'] ?? '',
      handle: json['handle'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      notificationsEnabled: json['notificationsEnabled'] ?? false,
      fcmToken: json['fcmToken'],
      astroData: AstroDataModel.fromJson(json['astroData'] ?? {}),
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
      'handle': handle,
      'phoneNumber': phoneNumber,
      'notificationsEnabled': notificationsEnabled,
      'fcmToken': fcmToken,
      'astroData': astroData.toJson(),
    };
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel.fromJson(data);
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? dateOfBirth,
    String? placeOfBirth,
    String? photoUrl,
    String? gender,
    String? handle,
    String? phoneNumber,
    bool? notificationsEnabled,
    String? fcmToken,
    AstroDataModel? astroData,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      photoUrl: photoUrl ?? this.photoUrl,
      gender: gender ?? this.gender,
      handle: handle ?? this.handle,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      fcmToken: fcmToken ?? this.fcmToken,
      astroData: astroData ?? this.astroData,
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
