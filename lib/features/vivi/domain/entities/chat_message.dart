import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String role;
  final String content;
  final int index;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.index,
  });

  bool get isUser => role == 'user';

  @override
  List<Object?> get props => [role, content, index];
}
