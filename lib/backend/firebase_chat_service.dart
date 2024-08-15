import 'package:chatview/chatview.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:test1/models/user.dart';

Message mapToMessage(Map<dynamic, dynamic> map) {
  return Message(
    id: map['id'] as String,
    message: map['message'] as String,
    createdAt: parseDate(map['createdAt'] as String),
    sendBy: map['sendBy'] as String,
    // You need to map other properties based on what Message constructor requires
    // Add handling for any enums or other specific types required by the Message constructor
  );
}

Map<String, dynamic> messageToMap(Message message) {
  return {
    'id': message.id,
    'message': message.message,
    'createdAt':
        message.createdAt.toIso8601String(), // Assuming createdAt is a DateTime
    'sendBy': message.sendBy,
    // Continue mapping other necessary fields from the Message object
    // If there are enums or complex objects, convert them to simple string or numeric representations
  };
}

class FirebaseChatService {
  final DatabaseReference _messagesRef =
      FirebaseDatabase.instance.ref('messages');

  Stream<List<Message>> getMessagesStream(String chatRoomId) {
    return _messagesRef.child(chatRoomId).onValue.map((event) {
      List<Message> messages = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        messages.addAll(data.entries
            .map((e) => mapToMessage(e.value as Map<dynamic, dynamic>)));
      }
      return messages;
    });
  }

  Future<void> sendMessage(String chatRoomId, Message message) {
    return _messagesRef.child(chatRoomId).push().set(messageToMap(message));
  }
}
