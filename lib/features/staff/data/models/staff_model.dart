import 'package:viora_app/features/staff/domain/entities/staff.dart';

class StaffModel {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String gender;
  final DateTime? dateOfBirth;

  const StaffModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phoneNumber = '',
    this.gender = '',
    this.dateOfBirth,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    DateTime? dob;
    if (json['dateOfBirth'] != null && json['dateOfBirth'] is String) {
      dob = DateTime.tryParse(json['dateOfBirth'] as String);
    }
    return StaffModel(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      dateOfBirth: dob,
    );
  }

  Staff toEntity() => Staff(
        id: id,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );
}
