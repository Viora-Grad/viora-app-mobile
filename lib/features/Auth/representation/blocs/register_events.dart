import 'package:equatable/equatable.dart';
import 'package:viora_app/core/enums/gender.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

final class RegisterSubmitted extends RegisterEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final Gender gender;
  final DateTime dateOfBirth;

  const RegisterSubmitted({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    firstName,
    lastName,
    gender,
    dateOfBirth,
  ];
}

final class OAuthRegisterSubmitted extends RegisterEvent {
  final String email;
  final String firstName;
  final String lastName;
  final Gender gender;
  final DateTime dateOfBirth;
  final String providerKey;

  const OAuthRegisterSubmitted({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    required this.providerKey,
  });

  @override
  List<Object?> get props => [
    email,
    firstName,
    lastName,
    gender,
    dateOfBirth,
    providerKey,
  ];
}

final class RegisterReset extends RegisterEvent {
  const RegisterReset();
}