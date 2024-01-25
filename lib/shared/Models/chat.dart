enum MessageType { text, image, audio }

enum MessageStatus { sending, delivered, read }

class Message {
  String id = '';
  String senderId = '';
  String receiverId = '';
  String message = '';
  DateTime time = DateTime.now();
  MessageType type = MessageType.text;
  MessageStatus status = MessageStatus.sending;

  Message();

  Message.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    senderId = map['senderId'];
    receiverId = map['receiverId'];
    message = map['message'];
    time = map['time'].toDate(); // Convert Timestamp to DateTime
    type = MessageType.values[map['type']];
    status = MessageStatus.values[map['status']];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'time': time, // Convert DateTime to Timestamp done by Firestore
      'type': type.index,
      'status': status.index,
    };
  }
}

class ChatUser {
  String id = '';
  String name = '';
  String imageUrl = '';
  int unreadMessages = 0;

  ChatUser();

  ChatUser.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    imageUrl = map['imageUrl'];
    unreadMessages = map['unreadMessages'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'unreadMessages': unreadMessages,
    };
  }
}

class ChatRoom {
  String id = '';
  List<String> users = [];
  ChatUser user1 = ChatUser();
  ChatUser user2 = ChatUser();

  ChatRoom(ChatUser user1, ChatUser user2) {
    user1 = user1;
    user2 = user2;
    users.add(user1.id);
    users.add(user2.id);
  }

  ChatRoom.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    users = List<String>.from(map['users']);
    user1 = ChatUser.fromMap(map['user1']);
    user2 = ChatUser.fromMap(map['user2']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'users': users,
      'user1': user1.toMap(),
      'user2': user2.toMap(),
    };
  }
}
