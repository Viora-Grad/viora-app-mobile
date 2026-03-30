import 'package:flutter/material.dart';

class RegisterSubmitButton extends StatelessWidget {
  const RegisterSubmitButton({
    required this.isSubmitting,
    required this.onPressed,
    super.key,
  });

  static const Color _gradientStart = Color(0xFF00D5FF);
  static const Color _gradientEnd = Color(0xFF28F0A8);

  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isSubmitting;

    return SizedBox(
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isEnabled
                ? const [_gradientStart, _gradientEnd]
                : [
                    _gradientStart.withValues(alpha: 0.35),
                    _gradientEnd.withValues(alpha: 0.35),
                  ],
          ),
          boxShadow: isEnabled
              ? const [
                  BoxShadow(
                    color: Color(0x3300D5FF),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Create Account',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
