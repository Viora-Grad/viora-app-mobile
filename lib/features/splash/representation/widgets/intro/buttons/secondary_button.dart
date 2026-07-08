import 'package:flutter/material.dart';

class SecondaryStepButton extends StatelessWidget {
  const SecondaryStepButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  static const Color _secondaryForeground = Color(0xFFA39AB8);

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
        foregroundColor: _secondaryForeground,
        splashFactory: NoSplash.splashFactory,
      ),
      icon: Icon(
        icon,
        size: 16,
        color: isEnabled
            ? _secondaryForeground
            : _secondaryForeground.withValues(alpha: 0.4),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isEnabled
              ? _secondaryForeground
              : _secondaryForeground.withValues(alpha: 0.4),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
