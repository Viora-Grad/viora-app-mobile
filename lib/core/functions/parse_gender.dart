import 'package:viora_app/core/enums/gender.dart';

Gender parseGender(dynamic value) {
  if (value is int && value >= 0 && value < Gender.values.length) {
    return Gender.values[value];
  }

  if (value is String) {
    final normalized = value.toLowerCase();
    if (normalized == 'female') {
      return Gender.female;
    }

    if (normalized == 'male') {
      return Gender.male;
    }
    final matched = Gender.values.where((g) => g.name == normalized);
    if (matched.isNotEmpty) {
      return matched.first;
    }
  }
  return Gender.male;
}
