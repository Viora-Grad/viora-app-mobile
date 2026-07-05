import 'package:flutter/material.dart';

const double _buttonHeight56 = 56.0;
const double _borderRadius16 = 16.0;
const double _shadowBlur18 = 18.0;
const double _shadowOffsetY10 = 10.0;
const double _loaderSize24 = 24.0;
const double _progressStrokeWidth24 = 2.4;
const double _fontText18 = 18.0;
const double _letterSpacing02 = 0.2;

class LoginSubmitButton extends StatelessWidget {
  const LoginSubmitButton({
    required this.isSubmitting,
    required this.onPressed,
    super.key,
  });

  static const Color _primary = Color(0xFF2F1193);

  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isSubmitting;

    return SizedBox(
      height: _buttonHeight56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_borderRadius16),
          color: isEnabled
              ? _primary
              : _primary.withValues(alpha: 0.35),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.20),
                    blurRadius: _shadowBlur18,
                    offset: const Offset(0, _shadowOffsetY10),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(_borderRadius16),
            child: Center(
              child: isSubmitting
                  ? const SizedBox(
                      width: _loaderSize24,
                      height: _loaderSize24,
                      child: CircularProgressIndicator(
                        strokeWidth: _progressStrokeWidth24,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: _fontText18,
                        color: Colors.white,
                        letterSpacing: _letterSpacing02,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
