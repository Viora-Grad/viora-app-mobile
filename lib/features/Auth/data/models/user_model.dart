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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      userName: json['userName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      gender: Gender.values[json['gender']],
      age: json['age'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      profilePictureUrl: json['profilePictureUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
      'gender': gender.index,
      'age': age,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profilePictureUrl': profilePictureUrl,
    };
  }
}
