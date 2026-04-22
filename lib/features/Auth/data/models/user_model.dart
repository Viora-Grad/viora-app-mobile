import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/features/auth/domain/entities/user.dart';

// Brief: This is the UserModel class, which represents the user data structure
// used in the data layer. It includes methods for converting to/from JSON
// and to/from the User entity used in the domain layer.

class UserModel {
  final String id;
  final String userName;
  final String email;
  final String? profilePictureUrl;
  final String phoneNumber;
  final Gender gender;
  final int age;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
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

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      userName: user.userName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      gender: user.gender,
      age: user.age,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      profilePictureUrl: user.profilePictureUrl,
    );
  }

  User toEntity() {
    return User(
      id: id,
      userName: userName,
      email: email,
      phoneNumber: phoneNumber,
      gender: gender,
      age: age,
      createdAt: createdAt,
      updatedAt: updatedAt,
      profilePictureUrl: profilePictureUrl,
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

    return Gender.male;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      gender: _parseGender(json['gender']),
      age: (json['age'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      profilePictureUrl: json['profilePictureUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
      'gender': gender.name,
      'age': age,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profilePictureUrl': profilePictureUrl,
    };
  }
}
