import 'package:equatable/equatable.dart';
import 'package:viora_app/core/enums/gender.dart';

// Brief: This is the User entity class, which represents the user data structure
// used in the domain layer. It is a plain Dart class that extends Equatable
// for value equality.

class User extends Equatable {
  final String id;
  final String userName;
  final String email;
  final String? profilePictureUrl;
  final String phoneNumber;
  final Gender gender;
  final int age;

  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    required this.age,
    required this.createdAt,
    required this.updatedAt,
    this.profilePictureUrl,
  });

  @override
  List<Object?> get props => [
    id,
    userName,
    email,
    profilePictureUrl,
    phoneNumber,
    gender,
    age,
    createdAt,
    updatedAt,
  ];
}
