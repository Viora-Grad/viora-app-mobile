import 'package:flutter/material.dart';

InputDecoration _inputDecoration({required String label, Widget? suffixIcon}) {
  return InputDecoration(
    labelText: label,
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
    suffixIcon: suffixIcon,
  );
}

class TouchedFormField extends StatefulWidget {
  const TouchedFormField({
    required this.controller,
    required this.label,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
    this.style,
    this.obscureText = false,
    this.enabled = true,
    this.suffixIcon,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final bool obscureText;
  final bool enabled;
  final Widget? suffixIcon;

  @override
  State<TouchedFormField> createState() => _TouchedFormFieldState();
}

class _TouchedFormFieldState extends State<TouchedFormField> {
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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      style: widget.style,
      decoration: _inputDecoration(
        label: widget.label,
        suffixIcon: widget.suffixIcon,
      ),
      validator: (value) => _touched ? widget.validator(value) : null,
    );
  }
}
