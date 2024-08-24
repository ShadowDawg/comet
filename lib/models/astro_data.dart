import 'package:cloud_firestore/cloud_firestore.dart';

class AstroDataModel {
  final String uid;
  final String dailyHoroscope;
  final String detailedReading;
  final String matchUid;
  bool matchApproved;
  final String lastUpdated;
  String chatRoomId;
  final Map<String, dynamic> planetSigns;
  final Map<String, List<String>> actionTable;

  AstroDataModel({
    required this.uid,
    required this.dailyHoroscope,
    required this.detailedReading,
    required this.matchUid,
    required this.matchApproved,
    required this.lastUpdated,
    required this.chatRoomId,
    required this.planetSigns,
    required this.actionTable,
  });

  factory AstroDataModel.fromJson(Map<String, dynamic> json) {
    String sanitizeString(String? input) {
      print("AYY: $input");
      if (input == null) return '';
      return input.replaceAll('—', '-').replaceAll('’', "'");
    }

    return AstroDataModel(
      uid: json['uid'] ?? '',
      dailyHoroscope: sanitizeString(json['dailyHoroscope']),
      detailedReading: sanitizeString(json['detailedReading']),
      matchUid: json['matchUid'] ?? '',
      matchApproved: json['matchApproved'] ?? false,
      lastUpdated: json['lastUpdated'],
      chatRoomId: json['chatRoomId'] ?? 'hmm',
      planetSigns: json['planetSigns'] as Map<String, dynamic>? ?? {},
      actionTable: _parseActionTable(json['actionTable']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'dailyHoroscope': dailyHoroscope,
      'detailedReading': detailedReading,
      'matchUid': matchUid,
      'matchApproved': matchApproved,
      // 'lastUpdated': lastUpdated,
      'lastUpdated': lastUpdated, // DateTime is not json serializable
      'chatRoomId': chatRoomId,
      'planetSigns': planetSigns,
      'actionTable': actionTable,
    };
  }

  static Map<String, List<String>> _parseActionTable(dynamic actionTableData) {
    if (actionTableData is Map<String, dynamic>) {
      return {
        'yes': List<String>.from(actionTableData['yes'] ?? []),
        'no': List<String>.from(actionTableData['no'] ?? []),
      };
    }
    return {
      "yes": ["Afternoon Naps", "Group Studies", "Bunk Class"],
      "no": ["Usha Cafe", "Gossip", "Masala Dosa"]
    };
  }

  AstroDataModel copyWith({
    String? uid,
    String? dailyHoroscope,
    String? detailedReading,
    String? matchUid,
    bool? matchApproved,
    String? lastUpdated,
    String? chatRoomId,
    Map<String, dynamic>? planetSigns,
    Map<String, List<String>>? actionTable,
  }) {
    return AstroDataModel(
      uid: uid ?? this.uid,
      dailyHoroscope: dailyHoroscope ?? this.dailyHoroscope,
      detailedReading: detailedReading ?? this.detailedReading,
      matchUid: matchUid ?? this.matchUid,
      matchApproved: matchApproved ?? this.matchApproved,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      planetSigns: planetSigns ?? this.planetSigns,
      actionTable: actionTable ?? this.actionTable,
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
