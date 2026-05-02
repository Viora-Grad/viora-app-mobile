class LoginValidators {
  const LoginValidators._();

  static String? validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Invalid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Password is required';
    }
    if (trimmed.length < 8) {
      return 'Min 8 characters';
    }

    final hasLowercase = RegExp(r'[a-z]').hasMatch(trimmed);
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(trimmed);
    final hasNumber = RegExp(r'\d').hasMatch(trimmed);

    if (!hasLowercase || !hasUppercase || !hasNumber) {
      return 'Use upper, lower, and number';
    }

    return null;
  }

  static List<String> collectInvalidFields({
    required String email,
    required String password,
  }) {
    final invalidFields = <String>[];

    void addFieldError(String? error, String fieldName) {
      if (error != null) {
        invalidFields.add(fieldName);
      }
    }

    addFieldError(validateEmail(email), 'Email');
    addFieldError(validatePassword(password), 'Password');

    return invalidFields;
  }

  static String buildValidationSummary(List<String> invalidFields) {
    final count = invalidFields.length;
    final fields = invalidFields.join(', ');
    final errorWord = count == 1 ? 'error' : 'errors';

    return '$count $errorWord found in $fields';
  }
}
