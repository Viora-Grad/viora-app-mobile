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

  static String staffDayShiftUrl({
    required String staffId,
    required String shiftId,
    required String day,
  }) =>
      '$baseUrl/api/schedule/staff?StaffId=$staffId&ShiftId=$shiftId&day=$day';

  // AI Chat
  static const String aiChatUrl = '$baseUrl/api/ai/chats';
  static const String aiSessionsUrl = '$baseUrl/api/ai/sessions';

  // Services
  static String servicesByBranchUrl(String branchId) =>
      '$baseUrl/api/branch/$branchId/services';

  // Staff / Doctors
  static String staffByBranchServiceUrl(String branchId, String serviceId) =>
      '$baseUrl/api/staffs/branches/$branchId/services/$serviceId';

  static String branchScheduleUrl(String branchId) =>
      '$baseUrl/api/schedule/$branchId';

  // Staff
  static const String staffsUrl = '$baseUrl/api/Staffs';

  // Branch details
  static String branchDetailsUrl(String branchId) =>
      '$baseUrl/api/Branches/$branchId';

  // Appointments
  static String staffScheduleUrl(String branchId, String staffId) =>
      '$baseUrl/api/branch/$branchId/schedule/staff/$staffId';

  static String doctorAppointmentsUrl(String doctorId) =>
      '$baseUrl/doctors/$doctorId';

  static const String createAppointmentUrl = '$baseUrl/api/appointments';

  // Customer / Medical Record
  static const String customerCreateUrl = '$baseUrl/create';
  static const String medicalRecordUrl = '$baseUrl/api/customer/medicalrecord';

  // User Appointments
  static String customerAppointmentsUrl(String customerId) =>
      '$baseUrl/customers/$customerId';

  static String cancelAppointmentUrl(String appointmentId) =>
      '$baseUrl/api/appointments/$appointmentId/cancel';

  // Prescription
  static String prescriptionByAppointmentUrl(String appointmentId) =>
      '$baseUrl/api/prescription/appointment/$appointmentId';

  // Wallet
  static const String walletCustomerUrl = '$baseUrl/api/wallets/customer';
  static const String walletRechargeUrl = '$baseUrl/api/wallets/customer/recharge';
  static String walletBranchUrl(String branchId) =>
      '$baseUrl/api/wallets/branch/$branchId';
  static String walletBranchCheckoutUrl(String branchId) =>
      '$baseUrl/api/wallets/branch/$branchId/checkout';

  // Forms
  static String serviceFormUrl(String serviceId) =>
      '$baseUrl/api/service/$serviceId/form';

  static String formByIdUrl(String formId) =>
      '$baseUrl/api/service/form/$formId';

  static String formSubmissionUrl(String appointmentId) =>
      '$baseUrl/api/appontment/$appointmentId/form-submission';

  static String formFileUploadUrl(String formSubmissionId) =>
      '$baseUrl/api/form/submission/file/$formSubmissionId';

  static String formSubmissionFileUrl(String formSubmissionId, String fileId) =>
      '$baseUrl/api/form/submission/file/$formSubmissionId/$fileId';
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
