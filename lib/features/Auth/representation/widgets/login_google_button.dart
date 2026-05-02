import 'package:flutter/material.dart';

const double _buttonHeight56 = 56.0;
const double _borderRadius16 = 16.0;
const double _disabledAlpha40 = 0.40;
const double _iconSize22 = 22.0;
const double _fontText16 = 16.0;
const double _loaderSize24 = 24.0;
const double _progressStrokeWidth24 = 2.4;

class LoginGoogleButton extends StatelessWidget {
  const LoginGoogleButton({
    required this.isSubmitting,
    required this.onPressed,
    super.key,
  });

  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isSubmitting;

    return SizedBox(
      height: _buttonHeight56,
      child: OutlinedButton.icon(
        onPressed: isEnabled ? onPressed : null,
        icon: isSubmitting
            ? const SizedBox(
                width: _loaderSize24,
                height: _loaderSize24,
                child: CircularProgressIndicator(
                  strokeWidth: _progressStrokeWidth24,
                ),
              )
            : const Icon(Icons.g_mobiledata, size: _iconSize22),
        label: const Text(
          'Sign in with Google',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: _fontText16,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(
                  alpha: isEnabled ? 1 : _disabledAlpha40,
                ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius16),
          ),
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}
