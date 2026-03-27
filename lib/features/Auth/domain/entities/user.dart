enum Gender {
  male,
  female
}

class User {
  final String id;
  final String userName;
  final String email;
  final String? profilePictureUrl;
  final String phoneNumber;
  final Gender gender;
  final int age;

  final DateTime createdAt;
  final DateTime updatedAt;

  User({
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
}
