import 'package:flutter/material.dart';
import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/features/auth/representation/widgets/register_password_field.dart';

const double _spacing10 = 10.0;
const double _spacing16 = 16.0;

class RegisterFormFields extends StatelessWidget {
  const RegisterFormFields({
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.selectedGender,
    required this.selectedDateOfBirth,
    required this.isSubmitting,
    required this.inputTextStyle,
    required this.firstNameValidator,
    required this.lastNameValidator,
    required this.emailValidator,
    this.passwordValidator,
    required this.onGenderChanged,
    required this.onDateOfBirthChanged,
    this.hidePasswordField = false,
    super.key,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Gender selectedGender;
  final DateTime? selectedDateOfBirth;
  final bool isSubmitting;
  final TextStyle? inputTextStyle;
  final String? Function(String?) firstNameValidator;
  final String? Function(String?) lastNameValidator;
  final String? Function(String?) emailValidator;
  final String? Function(String?)? passwordValidator;
  final ValueChanged<Gender> onGenderChanged;
  final ValueChanged<DateTime> onDateOfBirthChanged;
  final bool hidePasswordField;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: firstNameController,
                enabled: !isSubmitting,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                style: inputTextStyle,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: firstNameValidator,
              ),
            ),
            const SizedBox(width: _spacing10),
            Expanded(
              child: TextFormField(
                controller: lastNameController,
                enabled: !isSubmitting,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                style: inputTextStyle,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: lastNameValidator,
              ),
            ),
          ],
        ),
        const SizedBox(height: _spacing16),
        TextFormField(
          controller: emailController,
          enabled: !isSubmitting,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: inputTextStyle,
          decoration: const InputDecoration(labelText: 'Email'),
          validator: emailValidator,
        ),
        if (!hidePasswordField) ...[
          const SizedBox(height: _spacing16),
          RegisterPasswordField(
            controller: passwordController,
            isSubmitting: isSubmitting,
            inputTextStyle: inputTextStyle,
            validator: passwordValidator ?? (v) => null,
          ),
        ],
        const SizedBox(height: _spacing16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Gender>(
                value: selectedGender,
                style: inputTextStyle,
                decoration: const InputDecoration(labelText: 'Gender'),
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
                onChanged: isSubmitting
                    ? null
                    : (value) {
                        if (value == null) return;
                        onGenderChanged(value);
                      },
              ),
            ),
            const SizedBox(width: _spacing10),
            Expanded(
              child: InkWell(
                onTap: isSubmitting
                    ? null
                    : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              selectedDateOfBirth ??
                              DateTime(DateTime.now().year - 18),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          onDateOfBirthChanged(picked);
                        }
                      },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                  ),
                  child: Text(
                    selectedDateOfBirth != null
                        ? '${selectedDateOfBirth!.day.toString().padLeft(2, '0')}/'
                              '${selectedDateOfBirth!.month.toString().padLeft(2, '0')}/'
                              '${selectedDateOfBirth!.year}'
                        : 'Select date',
                    style: inputTextStyle,
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