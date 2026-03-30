import 'package:viora_app/core/enums/gender.dart';
import 'package:equatable/equatable.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

final class RegisterSubmitted extends RegisterEvent {
  final String email;
  final String password;
  final String userName;
  final String phoneNumber;
  final String? profilePicturePath;
  final int age;
  final Gender gender;

  const RegisterSubmitted({
    required this.email,
    required this.password,
    required this.userName,
    required this.phoneNumber,
    this.profilePicturePath,
    required this.age,
    required this.gender,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    userName,
    phoneNumber,
    profilePicturePath,
    age,
    gender,
  ];
}

final class RegisterReset extends RegisterEvent {
  const RegisterReset();
}
