import 'package:flutter/material.dart';
import 'package:viora_app/features/vivi/domain/entities/chat_message.dart';
import 'package:viora_app/features/vivi/representation/widgets/streaming_text.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isStreaming;

  const MessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 0),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _ViviAvatar(),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF2F1193)
                    : const Color(0xFFF5F3FC),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: isUser || !isStreaming
                  ? Text(
                      message.content,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 14.5,
                        height: 1.45,
                      ),
                    )
                  : StreamingAiText(
                      text: message.content,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14.5,
                        height: 1.45,
                      ),
                    ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _UserAvatar(),
        ],
      ),
    );
  }
}

class _ViviAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF2F1193), Color(0xFF6B3FA0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Center(
      child: Text(
        'V',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(
      color: const Color(0xFFE8E8EE),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(Icons.person_rounded, size: 18, color: Colors.grey),
  );
}
