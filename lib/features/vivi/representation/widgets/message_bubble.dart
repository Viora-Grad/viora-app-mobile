import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/features/vivi/domain/entities/ai_action.dart';
import 'package:viora_app/features/vivi/domain/entities/chat_message.dart';
import 'package:viora_app/features/vivi/representation/widgets/streaming_text.dart';

const Color _primary = Color(0xFF2F1193);
const Color _bg = Color(0xFFF5F3FC);

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
          if (!isUser) const _ViviAvatar(),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildBubble(context),
                if (!isUser && message.actions.isNotEmpty)
                  _buildActions(context),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) const _UserAvatar(),
        ],
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    final isUser = message.isUser;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser
            ? _primary
            : _bg,
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
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: message.actions.map((action) {
          return _ActionChip(action: action);
        }).toList(),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final AiAction action;

  const _ActionChip({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.branchSearch,
        extra: action.specialty,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              action.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViviAvatar extends StatelessWidget {
  const _ViviAvatar();

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
  const _UserAvatar();

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


