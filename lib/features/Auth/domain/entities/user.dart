import 'package:equatable/equatable.dart';
import 'package:viora_app/core/enums/gender.dart';

class User extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final Gender gender;
  final DateTime dateOfBirth;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.dateOfBirth,
  });

  String get userName => '$firstName $lastName';

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    gender,
    dateOfBirth,
  ];
}
