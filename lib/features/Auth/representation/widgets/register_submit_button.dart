import 'package:flutter/material.dart';

class RegisterSubmitButton extends StatelessWidget {
  const RegisterSubmitButton({
    required this.isSubmitting,
    required this.onPressed,
    super.key,
  });

  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 56,
      child: FilledButton(
        onPressed: isSubmitting ? null : onPressed,
        child: isSubmitting
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: theme.colorScheme.onPrimary,
                ),
              )
            : Text(
                'Create Account',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }
}
