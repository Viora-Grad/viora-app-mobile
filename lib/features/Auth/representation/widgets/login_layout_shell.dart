import 'package:flutter/material.dart';
import 'package:viora_app/features/Auth/representation/widgets/login_page_header.dart';

class LoginLayoutShell extends StatelessWidget {
  const LoginLayoutShell({
    required this.formKey,
    required this.formTopSpacing,
    required this.child,
    this.footer,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final double formTopSpacing;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const LoginPageHeader(
                  title: 'Welcome Back',
                  subtitle: 'Sign in with your email and password',
                ),
                SizedBox(height: formTopSpacing * 0.45),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8E8EE)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2F1193).withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: child,
                ),
                if (footer != null) ...[
                  const SizedBox(height: 24),
                  Align(alignment: Alignment.center, child: footer!),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
