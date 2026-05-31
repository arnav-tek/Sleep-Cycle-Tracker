/// Utility class that calculates sleep quality from actual sleep duration.
///
/// Quality bands with smooth linear interpolation:
/// - < 4.5 hours  → 0–40%   (Poor)
/// - 4.5–6 hours  → 41–65%  (Fair)
/// - 6–7.5 hours  → 66–80%  (Good)
/// - 7.5–9 hours  → 81–100% (Optimal)
/// - > 9 hours    → scales back down to ~70% (oversleep penalty)
///
/// Skill: @architecture — stateless utility, fully testable, zero UI coupling.
library;

/// Result of a sleep quality calculation.
class SleepQualityResult {
  /// Creates a [SleepQualityResult].
  const SleepQualityResult({required this.percentage, required this.label});

  /// Quality percentage (0–100).
  final int percentage;

  /// Human-readable label: Poor, Fair, Good, or Optimal.
  final String label;
}

/// Provides sleep-quality calculations based on actual sleep duration.
///
/// Usage:
/// ```dart
/// final result = SleepQualityCalculator.calculate(7.0); // 6–7.5h band
/// print(result.percentage); // e.g. 73
/// print(result.label);      // 'Good'
/// ```
class SleepQualityCalculator {
  // Private constructor — prevent instantiation.
  SleepQualityCalculator._();

  /// Calculate sleep quality from [hours] of actual sleep.
  ///
  /// Returns a [SleepQualityResult] with a percentage (0–100) and a
  /// descriptive label. The percentage is smoothly interpolated within
  /// each quality band using linear interpolation.
  static SleepQualityResult calculate(double hours) {
    if (hours <= 0) {
      return const SleepQualityResult(percentage: 0, label: 'Poor');
    }

    int percentage;

    if (hours < 4.5) {
      // 0–40% (Poor)
      percentage = _lerp(0, 40, hours / 4.5);
    } else if (hours < 6.0) {
      // 41–65% (Fair)
      percentage = _lerp(41, 65, (hours - 4.5) / 1.5);
    } else if (hours < 7.5) {
      // 66–80% (Good)
      percentage = _lerp(66, 80, (hours - 6.0) / 1.5);
    } else if (hours <= 9.0) {
      // 81–100% (Optimal)
      percentage = _lerp(81, 100, (hours - 7.5) / 1.5);
    } else {
      // > 9 hours — oversleep penalty, scale back toward ~70%
      final overshoot = ((hours - 9.0) / 3.0).clamp(0.0, 1.0);
      percentage = _lerp(100, 70, overshoot);
    }

    percentage = percentage.clamp(0, 100);

    final label = _labelForPercentage(percentage);
    return SleepQualityResult(percentage: percentage, label: label);
  }

  /// Derives the mood indicator aligned with quality bands.
  ///
  /// - Poor  (0–40%)  → `'Tired'`
  /// - Fair  (41–65%) → `'Okay'`
  /// - Good+ (66–100%) → `'Happy'`
  static String moodForQuality(int percentage) {
    if (percentage <= 40) return 'Tired';
    if (percentage <= 65) return 'Okay';
    return 'Happy';
  }

  /// Linearly interpolate between [a] and [b] by factor [t] (0.0–1.0).
  static int _lerp(int a, int b, double t) {
    return (a + (b - a) * t.clamp(0.0, 1.0)).round();
  }

  /// Map a quality percentage to its descriptive label.
  static String _labelForPercentage(int percentage) {
    if (percentage <= 40) return 'Poor';
    if (percentage <= 65) return 'Fair';
    if (percentage <= 80) return 'Good';
    return 'Optimal';
  }
}
