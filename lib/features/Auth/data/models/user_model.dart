import 'package:viora_app/features/Auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String userName,
    required String email,
    required String phoneNumber,
    required Gender gender,
    required int age,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? profilePictureUrl,
  }) : super(
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
      if (normalized.contains('male')) return Gender.male;
      if (normalized.contains('female')) return Gender.female;
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
