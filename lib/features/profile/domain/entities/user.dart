import 'package:equatable/equatable.dart';
import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/features/profile/data/models/contact_model.dart';

// Brief: This is the User entity class, which represents the user data structure
// used in the domain layer. It is immutable and extends Equatable.

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final Gender gender;
  final String profilePictureUrl;
  final int age;
  final List<ContactModel> contacts;
  final List<String> organizationsVisited;
  final String? medicalRecordId;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    this.profilePictureUrl = '',
    required this.age,
    this.contacts = const [],
    this.organizationsVisited = const [],
    this.medicalRecordId,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    profilePictureUrl,
    gender,
    age,
    contacts,
    organizationsVisited,
    medicalRecordId,
  ];
}
