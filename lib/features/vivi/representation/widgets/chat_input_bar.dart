import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  final bool isSending;
  final void Function(String) onSend;
  final TextEditingController? controller;

  const ChatInputBar({
    super.key,
    required this.isSending,
    required this.onSend,
    this.controller,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isSending) return;
    _controller.clear();
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(color: Color(0xFFE8E8EE), width: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !widget.isSending,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              style: const TextStyle(
                  fontSize: 14.5, color: Colors.black87),
              decoration: const InputDecoration(
                hintText: 'Ask Vivi anything...',
                filled: true,
                fillColor: Color(0xFFF5F5F9),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(24)),
                  borderSide:
                      BorderSide(color: Color(0xFFE8E8EE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(24)),
                  borderSide:
                      BorderSide(color: Color(0xFFE8E8EE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(24)),
                  borderSide: BorderSide(
                      color: Color(0xFF2F1193), width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: Material(
              color: (_hasText && !widget.isSending)
                  ? const Color(0xFF2F1193)
                  : const Color(0xFFE8E8EE),
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _send,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: widget.isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.arrow_upward_rounded,
                          size: 20,
                          color: _hasText
                              ? Colors.white
                              : Colors.grey,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
