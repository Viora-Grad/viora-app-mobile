import 'package:equatable/equatable.dart';
import 'ai_action.dart';

class ChatMessage extends Equatable {
  final String role;
  final String content;
  final int index;
  final List<AiAction> actions;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.index,
    this.actions = const [],
  });

  bool get isUser => role == 'user';

  @override
  List<Object?> get props => [role, content, index, actions];
}
