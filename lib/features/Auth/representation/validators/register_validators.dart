class RegisterValidators {
  const RegisterValidators._();

  static const int nameMinChars2 = 2;
  static const int passwordMinChars8 = 8;

  static String? validateFirstName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'First name is required';
    }
    if (trimmed.length < nameMinChars2) {
      return 'Min 2 characters';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Last name is required';
    }
    if (trimmed.length < nameMinChars2) {
      return 'Min 2 characters';
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

  static String? validatePassword(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Password is required';
    }
    if (trimmed.length < passwordMinChars8) {
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

  static String? validateDateOfBirth(DateTime? date) {
    if (date == null) {
      return 'Date of birth is required';
    }

    final now = DateTime.now();
    int age = now.year - date.year;
    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      age--;
    }

    if (age < 13) {
      return 'Must be at least 13 years old';
    }
    if (age > 122) {
      return 'Invalid date of birth';
    }
    return null;
  }

  static List<String> collectInvalidFields({
    required String firstName,
    required String lastName,
    required String email,
    String? password,
    required DateTime? dateOfBirth,
  }) {
    final invalidFields = <String>[];

    void addFieldError(String? error, String fieldName) {
      if (error != null) {
        invalidFields.add(fieldName);
      }
    }

    addFieldError(validateFirstName(firstName), 'First Name');
    addFieldError(validateLastName(lastName), 'Last Name');
    addFieldError(validateEmail(email), 'Email');
    if (password != null) {
      addFieldError(validatePassword(password), 'Password');
    }
    addFieldError(validateDateOfBirth(dateOfBirth), 'Date of Birth');

    return invalidFields;
  }

  static String buildValidationSummary(List<String> invalidFields) {
    final count = invalidFields.length;
    final fields = invalidFields.join(', ');
    final errorWord = count == 1 ? 'error' : 'errors';

    return '$count $errorWord found in $fields';
  }
}
