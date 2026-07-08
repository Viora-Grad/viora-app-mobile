import 'package:viora_app/core/enums/gender.dart';

enum BmiCategory {
  underweight('Underweight', 0xFF2196F3),
  healthy('Healthy', 0xFF4CAF50),
  overweight('Overweight', 0xFFFF9800),
  obese('Obese', 0xFFF44336);

  const BmiCategory(this.label, this.colorValue);

  final String label;
  final int colorValue;
}

/// Body Mass Index assessment for a given weight, height and gender.
///
/// BMI itself is gender-neutral, but the guidance copy is tailored by gender so
/// the message reads naturally for the user.
class BmiResult {
  final double bmi;
  final BmiCategory category;
  final double healthyMinKg;
  final double healthyMaxKg;

  /// How the user's weight compares to the healthy range, as a signed
  /// percentage. 0 means within range; negative = below; positive = above.
  final double percentFromHealthy;
  final Gender gender;

  const BmiResult({
    required this.bmi,
    required this.category,
    required this.healthyMinKg,
    required this.healthyMaxKg,
    required this.percentFromHealthy,
    required this.gender,
  });

  bool get isHealthy => category == BmiCategory.healthy;

  factory BmiResult.calculate({
    required double weightKg,
    required double heightCm,
    required Gender gender,
  }) {
    final heightM = heightCm / 100.0;
    final bmi = weightKg / (heightM * heightM);

    // Standard adult BMI healthy band: 18.5 – 24.9.
    final healthyMin = 18.5 * heightM * heightM;
    final healthyMax = 24.9 * heightM * heightM;

    final BmiCategory category;
    if (bmi < 18.5) {
      category = BmiCategory.underweight;
    } else if (bmi < 25) {
      category = BmiCategory.healthy;
    } else if (bmi < 30) {
      category = BmiCategory.overweight;
    } else {
      category = BmiCategory.obese;
    }

    double percentFromHealthy = 0;
    if (weightKg < healthyMin) {
      percentFromHealthy = (weightKg - healthyMin) / healthyMin * 100;
    } else if (weightKg > healthyMax) {
      percentFromHealthy = (weightKg - healthyMax) / healthyMax * 100;
    }

    return BmiResult(
      bmi: bmi,
      category: category,
      healthyMinKg: healthyMin,
      healthyMaxKg: healthyMax,
      percentFromHealthy: percentFromHealthy,
      gender: gender,
    );
  }

  /// A friendly, gender-aware verdict for the given result.
  String get verdict {
    final subject = gender == Gender.female ? 'girl' : 'champ';
    switch (category) {
      case BmiCategory.healthy:
        return "Great news, $subject! Your weight is in a healthy range for "
            "your height. Keep it up! 🎉";
      case BmiCategory.underweight:
        return "You're a little below the healthy range for your height. "
            "Consider nourishing meals and a chat with a professional. 🥗";
      case BmiCategory.overweight:
        return "You're slightly above the healthy range. Small steps — more "
            "movement and mindful meals — go a long way. 💪";
      case BmiCategory.obese:
        return "Your weight is above the healthy range for your height. A "
            "doctor or nutritionist can help you build a safe plan. ❤️";
    }
  }
}
