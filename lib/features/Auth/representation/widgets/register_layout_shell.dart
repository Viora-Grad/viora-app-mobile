import 'package:flutter/material.dart';
import 'package:viora_app/features/auth/representation/widgets/register_page_header.dart';

class RegisterLayoutShell extends StatelessWidget {
  const RegisterLayoutShell({
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
    final theme = Theme.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF240D37),
                  const Color(0xFF240D37).withValues(alpha: 0.97),
                  const Color(0xFF1B0B2A),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -140,
          right: -70,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const SizedBox(width: 280, height: 280),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const RegisterPageHeader(
                    title: 'Create Account',
                    subtitle: 'Set up your profile to continue',
                  ),
                  SizedBox(height: formTopSpacing * 0.45),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.05,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.20),
                          blurRadius: 22,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: theme.copyWith(
                        inputDecorationTheme: theme.inputDecorationTheme
                            .copyWith(
                              filled: true,
                              fillColor: theme.colorScheme.surface.withValues(
                                alpha: 0.95,
                              ),
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
                  if (footer != null) ...[
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.center, child: footer!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
