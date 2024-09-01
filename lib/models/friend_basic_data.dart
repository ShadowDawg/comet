class FriendBasicData {
  final String name;
  final String handle;
  final String photoUrl;
  final String uid;
  final String phoneNumber;

  FriendBasicData({
    required this.name,
    required this.handle,
    required this.photoUrl,
    required this.uid,
    required this.phoneNumber,
  });

  factory FriendBasicData.fromJson(Map<String, dynamic> json) {
    return FriendBasicData(
      name: json['name'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'handle': handle,
      'photoUrl': photoUrl,
      'uid': uid,
      'phoneNumber': phoneNumber,
    };
  }

  @override
  String toString() {
    return 'FriendBasicData(name: $name, handle: $handle, photoUrl: $photoUrl, uid: $uid, phoneNumber: $phoneNumber)';
  }
}
