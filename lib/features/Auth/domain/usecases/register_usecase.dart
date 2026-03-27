import 'package:viora_app/features/Auth/domain/repositories/auth_repository.dart  ';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/Auth/domain/entities/user.dart';

class RegisterUsecase {
  final Authrepository repository;

  RegisterUsecase(this.repository);

  Future<User> call(RegisterParameters params) async {
    // Username validation
    if (params.userName.isEmpty) {
      throw Exception('Username cannot be empty');
    }

    // Email and password validation (same as login)
    if (params.email.isEmpty) {
      throw Exception('Email cannot be empty');
    }
    if (params.password.isEmpty) {
      throw Exception('Password cannot be empty');
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(params.email)) {
      throw Exception('Invalid email format');
    }
    if (params.password.length < 8) {
      throw Exception('Password must be at least 8 characters long');
    }
    if (!RegExp(r'[A-Z]').hasMatch(params.password)) {
      throw Exception('Password must contain at least one uppercase letter');
    }
    if (!RegExp(r'[a-z]').hasMatch(params.password)) {
      throw Exception('Password must contain at least one lowercase letter');
    }
    if (!RegExp(r'[0-9]').hasMatch(params.password)) {
      throw Exception('Password must contain at least one number');
    }

    // Phone number validation
    if (params.phoneNumber.isEmpty) {
      throw Exception('Phone number cannot be empty');
    }
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(params.phoneNumber)) {
      throw Exception('Invalid phone number format');
    }
    if (params.phoneNumber.length < 7 || params.phoneNumber.length > 15) {
      throw Exception('Phone number must be between 7 and 15 digits');
    }

    // Age validation
    if (params.age < 13) {
      throw Exception('You must be at least 13 years old to register');
    }
    if (!RegExp(r'^\d+$').hasMatch(params.age.toString())) {
      throw Exception('Age must be a valid number');
    }

    // Gender
    if (params.gender != Gender.male && params.gender != Gender.female) {
      throw Exception('Invalid gender value');
    }

    // Profile picture URL validation (optional)
    if (params.profilePictureUrl != null && params.profilePictureUrl!.isNotEmpty) {
      if (!Uri.tryParse(params.profilePictureUrl!)!.isAbsolute) {
        throw Exception('Invalid profile picture URL');
      }
    }

    return await repository.register(params);
  }
}
