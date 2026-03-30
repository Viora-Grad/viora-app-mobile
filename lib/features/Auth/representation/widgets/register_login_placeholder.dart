import 'package:flutter/material.dart';

class RegisterLoginPlaceholder extends StatelessWidget {
  const RegisterLoginPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Do you have an account? ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.88),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'Login',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
            decorationColor: theme.colorScheme.onPrimary,
          ),
        ),
        Text(
          ' (coming soon)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.72),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
