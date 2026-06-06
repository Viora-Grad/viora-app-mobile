import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/core/functions/parse_gender.dart';
import 'package:viora_app/features/profile/domain/entities/user.dart';
import 'package:viora_app/features/profile/data/models/contact_model.dart';
import 'package:viora_app/features/profile/data/models/personal_info_model.dart';

// Brief: This is the UserModel class, which represents the user data structure
// used in the data layer. It includes methods for converting to/from JSON
// and to/from the User entity used in the domain layer.

class UserModel {
  final String id;
  final String email;
  final String avatarUrl;
  final int age;
  final Gender gender;

  // New fields from backend Customer model
  final String? userName; // optional username
  final PersonalInfoModel? personalInfo;
  final DateTime? joinedAt;
  final String? medicalRecordId;
  final List<String> organizationsVisited;
  final List<ContactModel> contacts;

  const UserModel({
    required this.id,
    required this.email,
    required this.avatarUrl,
    required this.age,
    required this.gender,
    this.userName,
    this.personalInfo,
    this.joinedAt,
    this.medicalRecordId,
    this.organizationsVisited = const [],
    this.contacts = const [],
  });

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      avatarUrl: user.profilePictureUrl,
      age: user.age,
      gender: user.gender,
      userName: user.name,
    );
  }

  User toEntity() {
    // Build domain `User` from backend fields: prefer `personalInfo`, then `userName`.
    final fullName =
        (personalInfo != null &&
            (personalInfo!.firstName.isNotEmpty ||
                personalInfo!.lastName.isNotEmpty))
        ? '${personalInfo!.firstName}${personalInfo!.lastName.isNotEmpty ? ' ${personalInfo!.lastName}' : ''}'
        : (userName ?? '');

    final derivedAge = personalInfo?.dateOfBirth != null
        ? personalInfo!.getAge(DateTime.now())
        : age;

    final derivedGender = personalInfo?.gender ?? gender;

    return User(
      id: id,
      name: fullName,
      email: email,
      profilePictureUrl: avatarUrl,
      age: derivedAge,
      gender: derivedGender,
      contacts: contacts,
      organizationsVisited: organizationsVisited,
      medicalRecordId: medicalRecordId,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      gender: parseGender(json['gender']),
      userName: json['userName'] as String?,
      personalInfo: json['personalInfo'] != null
          ? PersonalInfoModel.fromJson(
              json['personalInfo'] as Map<String, dynamic>,
            )
          : null,
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'] as String)
          : null,
      medicalRecordId: json['medicalRecordId'] as String?,
      organizationsVisited:
          (json['organizationsVisited'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      contacts:
          (json['contacts'] as List<dynamic>?)
              ?.map((e) => ContactModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'avatarUrl': avatarUrl,
      'age': age,
      'gender': gender.index,
      'userName': userName,
      'personalInfo': personalInfo?.toJson(),
      'joinedAt': joinedAt?.toIso8601String(),
      'medicalRecordId': medicalRecordId,
      'organizationsVisited': organizationsVisited,
      'contacts': contacts.map((c) => c.toJson()).toList(),
    };
  }
}


/*

  public sealed class Customer : Entity
  {
    private readonly HashSet<Guid> _organizationsVisited = [];
    private readonly HashSet<Contact> _contacts = [];
    public UserName? UserName { get; private set; }
    public PersonalInfo PersonalInfo { get; private set; } = null!;
    public DateTime JoinedAt { get; private set; }
    public Guid? MedicalRecordId { get; private set; } // can be removed since the relation is optional from the customer side
    public IReadOnlyList<Guid> OrganizationsVisited => _organizationsVisited.ToList().AsReadOnly();
    public IReadOnlyList<Contact> Contacts => _contacts.ToList().AsReadOnly();
    public User UserProfile { get; private set; } = null!; // navigation property for ef core
    public MedicalRecord? MedicalRecord { get; private set; } // navigation property for ef core
    public ICollection<OrganizationVisits> OrganizationVisits { get; private set; } = null!; // navigation property for ef core
  }  
  
  public sealed record PersonalInfo(
        string FirstName,
        string LastName,
        DateOnly DateOfBirth,
        Gender Gender)
    {
        public int GetAge(DateOnly today)
        {
            int age = today.Year - DateOfBirth.Year;

            if (today < DateOfBirth.AddYears(age))
            {
                age--;
            }

            return age;
        }

    }

*/