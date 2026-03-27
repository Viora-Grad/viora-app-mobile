import 'package:viora_app/features/Auth/domain/entities/user.dart';

class LoginParameters {
  final String email;
  final String password;
  
  LoginParameters({
    required this.email,
    required this.password,
  });
}

class RegisterParameters {
  final String userName;
  final String email;
  final String password;
  final String phoneNumber;
  final Gender gender;
  final int age;
  final String? profilePictureUrl;
  RegisterParameters({
    required this.userName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.gender,
    required this.age,
    this.profilePictureUrl,
  });
}
