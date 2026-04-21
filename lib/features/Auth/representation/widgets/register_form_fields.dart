import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/features/auth/representation/widgets/register_password_field.dart';

class RegisterFormFields extends StatelessWidget {
  const RegisterFormFields({
    required this.usernameController,
    required this.emailController,
    required this.phoneNumberController,
    required this.passwordController,
    required this.ageController,
    required this.selectedGender,
    required this.isSubmitting,
    required this.inputTextStyle,
    required this.usernameValidator,
    required this.emailValidator,
    required this.phoneNumberValidator,
    required this.passwordValidator,
    required this.ageValidator,
    required this.onGenderChanged,
    super.key,
  });

  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController phoneNumberController;
  final TextEditingController passwordController;
  final TextEditingController ageController;
  final Gender selectedGender;
  final bool isSubmitting;
  final TextStyle? inputTextStyle;
  final String? Function(String?) usernameValidator;
  final String? Function(String?) emailValidator;
  final String? Function(String?) phoneNumberValidator;
  final String? Function(String?) passwordValidator;
  final String? Function(String?) ageValidator;
  final ValueChanged<Gender> onGenderChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: usernameController,
          enabled: !isSubmitting,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          style: inputTextStyle,
          decoration: const InputDecoration(labelText: 'Username'),
          validator: usernameValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: emailController,
          enabled: !isSubmitting,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: inputTextStyle,
          decoration: const InputDecoration(labelText: 'Email'),
          validator: emailValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: phoneNumberController,
          enabled: !isSubmitting,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15),
          ],
          textInputAction: TextInputAction.next,
          style: inputTextStyle,
          decoration: const InputDecoration(labelText: 'Phone Number'),
          validator: phoneNumberValidator,
        ),
        const SizedBox(height: 16),
        RegisterPasswordField(
          controller: passwordController,
          isSubmitting: isSubmitting,
          inputTextStyle: inputTextStyle,
          validator: passwordValidator,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Gender>(
                value: selectedGender,
                style: inputTextStyle,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: Gender.values
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
                        if (value == null) {
                          return;
                        }
                        onGenderChanged(value);
                      },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: ageController,
                enabled: !isSubmitting,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                textInputAction: TextInputAction.done,
                style: inputTextStyle,
                decoration: const InputDecoration(labelText: 'Age'),
                validator: ageValidator,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
