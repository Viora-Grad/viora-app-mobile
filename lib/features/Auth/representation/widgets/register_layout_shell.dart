import 'package:flutter/material.dart';
import 'package:viora_app/features/Auth/representation/widgets/register_page_header.dart';

class RegisterLayoutShell extends StatelessWidget {
  const RegisterLayoutShell({
    required this.formKey,
    required this.formTopSpacing,
    required this.child,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final double formTopSpacing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/white_background.png',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.88),
                  theme.colorScheme.primary.withValues(alpha: 0.70),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.24, 0.45],
              ),
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const RegisterPageHeader(
                    title: 'Register',
                    subtitle: 'Create a new account',
                  ),
                  SizedBox(height: formTopSpacing),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Theme(
                      data: theme.copyWith(
                        inputDecorationTheme: theme.inputDecorationTheme
                            .copyWith(
                              labelStyle: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 16,
                              ),
                            ),
                      ),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
