import 'package:flutter/material.dart';
import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/features/auth/representation/widgets/register_password_field.dart';
import 'package:viora_app/features/auth/representation/widgets/touched_form_field.dart';

const double _spacing10 = 10.0;
const double _spacing16 = 16.0;

class RegisterFormFields extends StatefulWidget {
  const RegisterFormFields({
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.userNameController,
    required this.phoneNumberController,
    required this.selectedGender,
    required this.selectedDateOfBirth,
    required this.isSubmitting,
    required this.inputTextStyle,
    required this.firstNameValidator,
    required this.lastNameValidator,
    required this.emailValidator,
    this.passwordValidator,
    this.userNameValidator,
    this.phoneNumberValidator,
    required this.onGenderChanged,
    required this.onDateOfBirthChanged,
    this.hidePasswordField = false,
    super.key,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController userNameController;
  final TextEditingController phoneNumberController;
  final Gender selectedGender;
  final DateTime? selectedDateOfBirth;
  final bool isSubmitting;
  final TextStyle? inputTextStyle;
  final String? Function(String?) firstNameValidator;
  final String? Function(String?) lastNameValidator;
  final String? Function(String?) emailValidator;
  final String? Function(String?)? passwordValidator;
  final String? Function(String?)? userNameValidator;
  final String? Function(String?)? phoneNumberValidator;
  final ValueChanged<Gender> onGenderChanged;
  final ValueChanged<DateTime> onDateOfBirthChanged;
  final bool hidePasswordField;

  @override
  State<RegisterFormFields> createState() => _RegisterFormFieldsState();
}

class _RegisterFormFieldsState extends State<RegisterFormFields> {
  final _genderFocusNode = FocusNode();
  bool _genderTouched = false;
  bool _dobTouched = false;

  @override
  void dispose() {
    _genderFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TouchedFormField(
                controller: widget.firstNameController,
                label: 'First Name',
                enabled: !widget.isSubmitting,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                style: widget.inputTextStyle,
                validator: widget.firstNameValidator,
              ),
            ),
            const SizedBox(width: _spacing10),
            Expanded(
              child: TouchedFormField(
                controller: widget.lastNameController,
                label: 'Last Name',
                enabled: !widget.isSubmitting,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                style: widget.inputTextStyle,
                validator: widget.lastNameValidator,
              ),
            ),
          ],
        ),
        const SizedBox(height: _spacing16),
        TouchedFormField(
          controller: widget.emailController,
          label: 'Email',
          enabled: !widget.isSubmitting,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: widget.inputTextStyle,
          validator: widget.emailValidator,
        ),
        if (!widget.hidePasswordField) ...[
          const SizedBox(height: _spacing16),
          RegisterPasswordField(
            controller: widget.passwordController,
            isSubmitting: widget.isSubmitting,
            inputTextStyle: widget.inputTextStyle,
            validator: widget.passwordValidator ?? (v) => null,
          ),
        ],
        const SizedBox(height: _spacing16),
        TouchedFormField(
          controller: widget.userNameController,
          label: 'Username (optional)',
          enabled: !widget.isSubmitting,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          style: widget.inputTextStyle,
          validator: widget.userNameValidator ?? (v) => null,
        ),
        const SizedBox(height: _spacing16),
        TouchedFormField(
          controller: widget.phoneNumberController,
          label: 'Phone Number (optional)',
          enabled: !widget.isSubmitting,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          style: widget.inputTextStyle,
          validator: widget.phoneNumberValidator ?? (v) => null,
        ),
        const SizedBox(height: _spacing16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Gender>(
                value: widget.selectedGender,
                focusNode: _genderFocusNode,
                style: widget.inputTextStyle,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  filled: true,
                  fillColor: Color(0xFFF5F3FC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFF2F1193), width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFFF44336), width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFFF44336), width: 1.5),
                  ),
                  floatingLabelStyle: TextStyle(
                    color: Color(0xFF2F1193),
                    fontWeight: FontWeight.w600,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: Gender.values
                    .where((g) => g != Gender.unknown)
                    .map(
                      (gender) => DropdownMenuItem<Gender>(
                        value: gender,
                        child: Text(
                          gender.name[0].toUpperCase() +
                              gender.name.substring(1),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: widget.isSubmitting
                    ? null
                    : (value) {
                        if (value == null) return;
                        if (!_genderTouched) {
                          setState(() => _genderTouched = true);
                        }
                        widget.onGenderChanged(value);
                      },
                validator: (value) {
                  if (!_genderTouched) return null;
                  if (value == null || value == Gender.unknown) {
                    return 'Gender is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: _spacing10),
            Expanded(
              child: InkWell(
                onTap: widget.isSubmitting
                    ? null
                    : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              widget.selectedDateOfBirth ??
                              DateTime(DateTime.now().year - 18),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          if (!_dobTouched) {
                            setState(() => _dobTouched = true);
                          }
                          widget.onDateOfBirthChanged(picked);
                        } else if (!_dobTouched) {
                          setState(() => _dobTouched = true);
                        }
                      },
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
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
                    errorText: _dobTouched && widget.selectedDateOfBirth == null
                        ? 'Date of birth is required'
                        : null,
                  ),
                  child: Text(
                    widget.selectedDateOfBirth != null
                        ? '${widget.selectedDateOfBirth!.day.toString().padLeft(2, '0')}/'
                              '${widget.selectedDateOfBirth!.month.toString().padLeft(2, '0')}/'
                              '${widget.selectedDateOfBirth!.year}'
                        : 'Select date',
                    style: widget.inputTextStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
