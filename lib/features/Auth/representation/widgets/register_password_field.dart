import 'package:flutter/material.dart';

// Brief: This widget defines the password field for the registration form.
// It includes functionality to toggle the visibility of the password,
// allowing users to see or hide their input as needed.
// The field is also disabled when the form is being submitted to prevent changes during the submission process. 
// The validator function is used to ensure that the password meets the required criteria before allowing form submission.

class RegisterPasswordField extends StatefulWidget {
  const RegisterPasswordField({
    required this.controller,
    required this.isSubmitting,
    required this.validator,
    this.inputTextStyle,
    super.key,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final TextStyle? inputTextStyle;
  final String? Function(String?) validator;

  @override
  State<RegisterPasswordField> createState() => _RegisterPasswordFieldState();
}

class _RegisterPasswordFieldState extends State<RegisterPasswordField> {
  bool _obscurePassword = true;

  void _toggleVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: !widget.isSubmitting,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      style: widget.inputTextStyle,
      decoration: InputDecoration(
        labelText: 'Password',
        suffixIcon: IconButton(
          onPressed: widget.isSubmitting ? null : _toggleVisibility,
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
        ),
      ),
      validator: widget.validator,
    );
  }
}
