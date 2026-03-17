import 'package:flutter/material.dart';

class PrimaryStepButton extends StatelessWidget {
  const PrimaryStepButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  static const Color _primaryGradientStart = Color(0xFF00D5FF);
  static const Color _primaryGradientEnd = Color(0xFF28F0A8);

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: isEnabled
              ? const [_primaryGradientStart, _primaryGradientEnd]
              : [
                  _primaryGradientStart.withValues(alpha: 0.35),
                  _primaryGradientEnd.withValues(alpha: 0.35),
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
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
