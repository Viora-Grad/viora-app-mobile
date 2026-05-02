import 'package:flutter/material.dart';

enum AppSnackBarType { info, success, error }

class AppSnackBar {
  const AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
  }) {
    final theme = Theme.of(context);

    final ({Color background, Color foreground, IconData icon}) style =
        switch (type) {
          AppSnackBarType.success => (
            background: const Color(0xFF4CAF50), // Green
            foreground: Colors.white,
            icon: Icons.check_circle_rounded,
          ),
          AppSnackBarType.error => (
            background: const Color(0xFFF44336), // Red
            foreground: Colors.white,
            icon: Icons.error_rounded,
          ),
          AppSnackBarType.info => (
            background: const Color(0xFF2196F3), // Blue
            foreground: Colors.white,
            icon: Icons.info_rounded,
          ),
        };

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          backgroundColor: style.background,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: style.foreground.withValues(alpha: 0.30),
              width: 1,
            ),
          ),
          content: Row(
            children: [
              Icon(style.icon, color: style.foreground, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: style.foreground,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
