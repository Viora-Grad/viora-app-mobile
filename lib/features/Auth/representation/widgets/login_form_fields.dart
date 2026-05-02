import 'package:flutter/material.dart';
import 'package:viora_app/features/auth/representation/widgets/register_password_field.dart';

const double _spacing16 = 16.0;

class LoginFormFields extends StatelessWidget {
  const LoginFormFields({
    required this.emailController,
    required this.passwordController,
    required this.isSubmitting,
    required this.inputTextStyle,
    required this.emailValidator,
    required this.passwordValidator,
    super.key,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSubmitting;
  final TextStyle? inputTextStyle;
  final String? Function(String?) emailValidator;
  final String? Function(String?) passwordValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: emailController,
          enabled: !isSubmitting,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: inputTextStyle,
          decoration: const InputDecoration(labelText: 'Email'),
          validator: emailValidator,
        ),
        const SizedBox(height: _spacing16),
        RegisterPasswordField(
          controller: passwordController,
          isSubmitting: isSubmitting,
          inputTextStyle: inputTextStyle,
          validator: passwordValidator,
        ),
      ],
    );
  }
}
