import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/core/functions/parse_gender.dart';

class PersonalInfoModel {
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final Gender gender;

  PersonalInfoModel({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
  });

  int getAge(DateTime today) {
    if (dateOfBirth == null) return 0;
    int age = today.year - dateOfBirth!.year;
    final birthdayThisYear = DateTime(
      today.year,
      dateOfBirth!.month,
      dateOfBirth!.day,
    );
    if (today.isBefore(birthdayThisYear)) age--;
    return age;
  }

  factory PersonalInfoModel.fromJson(Map<String, dynamic> json) {
    return PersonalInfoModel(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      gender: parseGender(json['gender']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender.index,
    };
  }
}
