class EndPoints {
  // Android emulator -> host machine
  static const String baseUrl = 'http://10.0.2.2:5000';

  // Auth
  static const String loginUrl = '$baseUrl/api/auth/login';
  static const String registerUrl = '$baseUrl/api/auth/register';
  static const String refreshUrl = '$baseUrl/api/auth/refresh';
  static const String meUrl = '$baseUrl/api/auth/me';
  static const String googleValidateUrl = '$baseUrl/api/auth/oauth/google/validate';
  static const String googleOAuthLoginUrl = '$baseUrl/api/auth/oauth/google/login';
  static const String googleOAuthRegisterUrl = '$baseUrl/api/auth/oauth/google/register';

  // Profile
  static const String profileUrl = '$baseUrl/api/auth/me';
  static const String changePasswordUrl = '$baseUrl/api/auth/change-password';

  // Password Reset
  static const String forgetPasswordUrl = '$baseUrl/api/auth/forget-password';
  static const String confirmForgetPasswordUrl = '$baseUrl/api/auth/confirm-forget-password';

  // Search / Organizations
  static const String organizationsUrl = '$baseUrl/api/Organizations';
  static const String branchesUrl = '$baseUrl/api/Branches';
  static const String countriesUrl = '$baseUrl/api/Countries';
  static const String serviceTypesUrl = '$baseUrl/api/ServiceTypes';

  // Schedule
  static const String scheduleUrl = '$baseUrl/api/schedule';

  // AI Chat
  static const String aiChatUrl = '$baseUrl/api/ai/chats';
  static const String aiSessionsUrl = '$baseUrl/api/ai/sessions';

  // Customer / Medical Record
  static const String customerCreateUrl = '$baseUrl/create';
  static const String medicalRecordUrl = '$baseUrl/api/customer/medicalrecord';
}

class ApiKey {
  // Auth response keys
  static const String accessToken = 'accessToken';
  static const String refreshToken = 'refreshToken';
  static const String userId = 'userId';
  static const String roles = 'roles';
  static const String permissions = 'permissions';

  // User fields
  static const String id = 'id';
  static const String firstName = 'firstName';
  static const String lastName = 'lastName';
  static const String email = 'email';
  static const String phoneNumber = 'phoneNumber';
  static const String gender = 'gender';
  static const String dateOfBirth = 'dateOfBirth';
  static const String userName = 'userName';
  static const String profilePictureUrl = 'profilePictureUrl';
}
