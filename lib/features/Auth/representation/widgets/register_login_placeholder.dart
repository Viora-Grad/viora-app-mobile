import 'package:flutter/material.dart';

// Brief: This widget is a placeholder for the login option on the registration page. It informs users that the login feature is coming soon and encourages them to create an account if they don't have one. The text is styled to differentiate the call-to-action ("Login") from the rest of the message, while also indicating that the feature is not yet available. This helps manage user expectations and provides a clear path for those who want to register instead of logging in.
// TODO: Implement the actual login functionality and replace this placeholder with a navigable link to the login page once it's ready.

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
