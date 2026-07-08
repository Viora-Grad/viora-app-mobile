import 'package:flutter/material.dart';

class EmptyChatPlaceholder extends StatelessWidget {
  final ValueChanged<String>? onSuggestionTap;

  const EmptyChatPlaceholder({super.key, this.onSuggestionTap});

  static const _suggestions = [
    'How do I book an appointment?',
    'How does the check-in system work?',
    'Can I cancel my appointment?',
    'I have chest pain — what specialist should I see?',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2F1193),
                    Color(0xFF6B3FA0)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2F1193)
                        .withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'V',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Hi, I'm Vivi!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your Viora healthcare assistant.\nAsk me anything about the app or your health.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5),
            ),
            const SizedBox(height: 28),
            ..._suggestions.map(
                (s) => _SuggestionChip(text: s, onTap: onSuggestionTap)),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final ValueChanged<String>? onTap;
  const _SuggestionChip({required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => onTap?.call(text),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFFE8E8EE)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                      fontSize: 13.5,
                      color: Colors.black87,
                      fontWeight: FontWeight.w400),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
