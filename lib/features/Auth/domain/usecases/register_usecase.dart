import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/Auth/domain/entities/user.dart';
import 'package:viora_app/features/Auth/domain/repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  Future<Either<Failure, User>> call(
    RegisterParameters params, {
    CancelToken? cancelToken,
  }) async {
    if (params.firstName.isEmpty) {
      return const Left(ValidationFailure('First name cannot be empty'));
    }
    if (params.firstName.length < 2) {
      return const Left(ValidationFailure('First name must be at least 2 characters'));
    }

    if (params.lastName.isEmpty) {
      return const Left(ValidationFailure('Last name cannot be empty'));
    }
    if (params.lastName.length < 2) {
      return const Left(ValidationFailure('Last name must be at least 2 characters'));
    }

    if (params.email.isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(params.email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    if (params.password.isEmpty) {
      return const Left(ValidationFailure('Password cannot be empty'));
    }
    if (params.password.length < 8) {
      return const Left(ValidationFailure('Password must be at least 8 characters long'));
    }
    if (params.password.length > 100) {
      return const Left(ValidationFailure('Password must not exceed 100 characters'));
    }
    if (!RegExp(r'[A-Z]').hasMatch(params.password)) {
      return const Left(ValidationFailure('Password must contain at least one uppercase letter'));
    }
    if (!RegExp(r'[a-z]').hasMatch(params.password)) {
      return const Left(ValidationFailure('Password must contain at least one lowercase letter'));
    }
    if (!RegExp(r'[0-9]').hasMatch(params.password)) {
      return const Left(ValidationFailure('Password must contain at least one number'));
    }
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(params.password)) {
      return const Left(ValidationFailure('Password must contain at least one special character'));
    }

    if (params.gender != Gender.male && params.gender != Gender.female) {
      return const Left(ValidationFailure('Please select a valid gender'));
    }

    final now = DateTime.now();
    int age = now.year - params.dateOfBirth.year;
    if (now.month < params.dateOfBirth.month ||
        (now.month == params.dateOfBirth.month && now.day < params.dateOfBirth.day)) {
      age--;
    }
    if (age < 13) {
      return const Left(ValidationFailure('You must be at least 13 years old to register'));
    }

    return repository.register(params, cancelToken: cancelToken);
  }

  Future<Either<Failure, User>> oauthRegister({
    required String firstName,
    required String lastName,
    required String email,
    required Gender gender,
    required DateTime dateOfBirth,
    required String providerKey,
    String? userName,
    String? phoneNumber,
  }) async {
    if (firstName.isEmpty) {
      return const Left(ValidationFailure('First name cannot be empty'));
    }
    if (firstName.length < 2) {
      return const Left(ValidationFailure('First name must be at least 2 characters'));
    }

    if (lastName.isEmpty) {
      return const Left(ValidationFailure('Last name cannot be empty'));
    }
    if (lastName.length < 2) {
      return const Left(ValidationFailure('Last name must be at least 2 characters'));
    }

    if (email.isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    if (gender != Gender.male && gender != Gender.female) {
      return const Left(ValidationFailure('Please select a valid gender'));
    }

    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    if (age < 13) {
      return const Left(ValidationFailure('You must be at least 13 years old to register'));
    }

    final dateStr =
        '${dateOfBirth.year.toString().padLeft(4, '0')}-'
        '${dateOfBirth.month.toString().padLeft(2, '0')}-'
        '${dateOfBirth.day.toString().padLeft(2, '0')}';

    final genderStr = gender.name[0].toUpperCase() + gender.name.substring(1);

    return repository.oauthRegister(
      firstName: firstName,
      lastName: lastName,
      email: email,
      gender: genderStr,
      dateOfBirth: dateStr,
      providerKey: providerKey,
      userName: userName,
      phoneNumber: phoneNumber,
    );
  }
}
