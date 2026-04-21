class RegisterValidators {
  const RegisterValidators._();

  static String? validateUsername(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Username is required';
    }
    if (trimmed.length < 3) {
      return 'Min 3 characters';
    }
    if (RegExp(r'^\d+$').hasMatch(trimmed)) {
      return 'Cannot be numbers only';
    }
    return null;
  }

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

  static String? validatePhoneNumber(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Phone is required';
    }

    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 11) {
      return 'Min 11 digits';
    }
    if (digitsOnly.length > 15) {
      return 'Max 15 digits';
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

  static String? validateAge(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Age is required';
    }

    final parsedAge = int.tryParse(trimmed);
    if (parsedAge == null) {
      return 'Invalid age';
    }
    if (parsedAge < 16) {
      return 'Min age is 16';
    }
    if (parsedAge > 122) {
      return 'Max age is 122';
    }
    return null;
  }

  static List<String> collectInvalidFields({
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String age,
  }) {
    final invalidFields = <String>[];

    void addFieldError(String? error, String fieldName) {
      if (error != null) {
        invalidFields.add(fieldName);
      }
    }

    addFieldError(validateUsername(username), 'Username');
    addFieldError(validateEmail(email), 'Email');
    addFieldError(validatePhoneNumber(phoneNumber), 'Phone Number');
    addFieldError(validatePassword(password), 'Password');
    addFieldError(validateAge(age), 'Age');

    return invalidFields;
  }

  static String buildValidationSummary(List<String> invalidFields) {
    final count = invalidFields.length;
    final fields = invalidFields.join(', ');
    final errorWord = count == 1 ? 'error' : 'errors';

    return '$count $errorWord found in $fields';
  }
}
