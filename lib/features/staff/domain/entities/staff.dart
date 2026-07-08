import 'package:equatable/equatable.dart';
import 'staff_shift.dart';

class Staff extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String gender;
  final DateTime? dateOfBirth;
  final List<StaffShift> shifts;

  const Staff({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phoneNumber = '',
    this.gender = '',
    this.dateOfBirth,
    this.shifts = const [],
  });

  String get fullName => '$firstName $lastName';

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  List<String> get availableDays =>
      shifts.map((s) => s.day).toSet().toList();

  List<StaffShift> get shiftsForToday {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final today = days[DateTime.now().weekday - 1];
    return shifts.where((s) => s.day == today).toList();
  }

  Staff copyWith({List<StaffShift>? shifts}) =>
      Staff(
        id: id,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        gender: gender,
        dateOfBirth: dateOfBirth,
        shifts: shifts ?? this.shifts,
      );

  @override
  List<Object?> get props => [id, firstName, lastName, phoneNumber, gender, dateOfBirth, shifts];
}
