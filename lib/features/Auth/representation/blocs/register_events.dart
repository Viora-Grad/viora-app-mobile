import 'package:viora_app/core/enums/gender.dart';
import 'package:equatable/equatable.dart';

// Brief: This file defines the events for the RegisterBloc, which are used to
// trigger state changes in the registration process. The events include RegisterSubmitted
// for when the user submits the registration form, and RegisterReset for resetting
// the registration state. Each event extends Equatable for value equality, allowing
// the bloc to efficiently determine when to emit new states based on event changes.

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
  final int age;
  final Gender gender;

  const RegisterSubmitted({
    required this.email,
    required this.password,
    required this.userName,
    required this.phoneNumber,
    required this.age,
    required this.gender,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    userName,
    phoneNumber,
    age,
    gender,
  ];
}

final class RegisterReset extends RegisterEvent {
  const RegisterReset();
}
