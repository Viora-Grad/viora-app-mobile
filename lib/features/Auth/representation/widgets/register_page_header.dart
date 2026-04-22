import 'package:flutter/material.dart';

// Brief: This widget defines the header section of the registration page, 
// which includes a title and a subtitle.


class RegisterPageHeader extends StatelessWidget {
  const RegisterPageHeader({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 34,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.86),
            fontWeight: FontWeight.w500,
            fontSize: 16,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
