import 'package:viora_app/core/enums/gender.dart';

class LoginParameters {
  final String email;
  final String password;

  LoginParameters({required this.email, required this.password});
}

class RegisterParameters {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final Gender gender;
  final DateTime dateOfBirth;
  final String? userName;
  final String? phoneNumber;
  RegisterParameters({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.gender,
    required this.dateOfBirth,
    this.userName,
    this.phoneNumber,
  });
}
