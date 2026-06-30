import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/routes/app_router.dart';

class RegisterLoginPlaceholder extends StatelessWidget {
  const RegisterLoginPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        InkWell(
          onTap: () => context.push(AppRoutes.login),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              'Login',
              style: const TextStyle(
                color: Color(0xFF2F1193),
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF2F1193),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
