import 'package:viora_app/features/wellness/domain/sleep_entry.dart';

enum SleepQuality { none, tooLittle, healthy, tooMuch }

/// Aggregated guidance derived from the user's recent sleep log.
///
/// Uses the common adult recommendation of 7–9 hours per night.
class SleepAdvice {
  final double averageHours;
  final SleepQuality quality;
  final String message;

  const SleepAdvice({
    required this.averageHours,
    required this.quality,
    required this.message,
  });

  static const double _min = 7;
  static const double _max = 9;

  factory SleepAdvice.fromEntries(List<SleepEntry> entries) {
    if (entries.isEmpty) {
      return const SleepAdvice(
        averageHours: 0,
        quality: SleepQuality.none,
        message: 'Log a few nights and Vivi will share sleep tips for you.',
      );
    }

    final total = entries.fold<double>(0, (sum, e) => sum + e.durationHours);
    final avg = total / entries.length;

    if (avg < _min) {
      return SleepAdvice(
        averageHours: avg,
        quality: SleepQuality.tooLittle,
        message:
            "You're averaging ${avg.toStringAsFixed(1)}h a night — a bit short. "
            "Vivi suggests aiming for 7–9 hours to feel your best. 😴",
      );
    }
    if (avg > _max) {
      return SleepAdvice(
        averageHours: avg,
        quality: SleepQuality.tooMuch,
        message:
            "You're averaging ${avg.toStringAsFixed(1)}h a night — slightly long. "
            "Consistent 7–9 hours often feels more refreshing. 🌤️",
      );
    }
    return SleepAdvice(
      averageHours: avg,
      quality: SleepQuality.healthy,
      message:
          "Nicely done! You're averaging ${avg.toStringAsFixed(1)}h — right in "
          "the healthy 7–9 hour range. Keep that rhythm! 🌙",
    );
  }
}
