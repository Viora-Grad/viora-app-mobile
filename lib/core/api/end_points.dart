class EndPoints {
  // Android emulator -> host machine
  static const String baseUrl = 'http://10.0.2.2:8080';

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
