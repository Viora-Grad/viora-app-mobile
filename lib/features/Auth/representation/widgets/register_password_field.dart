import 'package:flutter/material.dart';

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
  late final FocusNode _focusNode;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && !_touched) {
      setState(() => _touched = true);
    }
  }

  void _toggleVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      enabled: !widget.isSubmitting,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      style: widget.inputTextStyle,
      decoration: InputDecoration(
        labelText: 'Password',
        filled: true,
        fillColor: const Color(0xFFF5F3FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2F1193), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF44336), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF44336), width: 1.5),
        ),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF2F1193),
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: IconButton(
          onPressed: widget.isSubmitting ? null : _toggleVisibility,
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
        ),
      ),
      validator: (value) => _touched ? widget.validator(value) : null,
    );
  }
}
