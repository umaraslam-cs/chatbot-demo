import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class Message {
  final String id;
  final String text;
  final DateTime createdAt;
  final String authorId;
  final String? authorName;

  Message({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.authorId,
    this.authorName,
  });

  factory Message.fromChatMessage(types.Message message) {
    return Message(
      id: message.id,
      text: (message as types.TextMessage).text,
      createdAt: DateTime.fromMillisecondsSinceEpoch(message.createdAt ?? DateTime.now().millisecondsSinceEpoch),
      authorId: message.author.id,
      authorName: message.author.firstName,
    );
  }

  types.Message toChatMessage() {
    return types.TextMessage(
      author: types.User(
        id: authorId,
        firstName: authorName,
      ),
      createdAt: createdAt.millisecondsSinceEpoch,
      id: id,
      text: text,
    );
  }

  /// ✅ Add this method
  Message copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    String? authorId,
    String? authorName,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
    );
  }
}
