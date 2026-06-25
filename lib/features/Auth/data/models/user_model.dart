import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/features/auth/domain/entities/user.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final Gender gender;
  final DateTime dateOfBirth;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.dateOfBirth,
  });

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      gender: user.gender,
      dateOfBirth: user.dateOfBirth,
    );
  }

  User toEntity() {
    return User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );
  }

  static Gender _parseGender(dynamic value) {
    if (value is int && value >= 0 && value < Gender.values.length) {
      return Gender.values[value];
    }

    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'female') return Gender.female;
      if (normalized == 'male') return Gender.male;
      final matched = Gender.values.where((g) => g.name == normalized);
      if (matched.isNotEmpty) return matched.first;
    }

    return Gender.unknown;
  }

  /// From backend /me endpoint response:
  /// { "firstName", "lastName", "email", "dateOfBirth", "gender" }
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      gender: _parseGender(json['gender']),
      dateOfBirth:
          DateTime.tryParse(json['dateOfBirth']?.toString() ?? '') ??
          DateTime(2000),
    );
  }

  /// From login response (AuthResult) - tokens are stored separately
  factory UserModel.fromAuthResult(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId']?.toString() ?? '',
      firstName: '',
      lastName: '',
      email: '',
      gender: Gender.unknown,
      dateOfBirth: DateTime(2000),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'gender': gender.name,
      'dateOfBirth': dateOfBirth.toIso8601String().split('T').first,
    };
  }
}
