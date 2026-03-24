/// Utility class that calculates optimal wake-up times based on
/// 90-minute sleep cycles.
///
/// Skill: @architecture — stateless utility, fully testable, zero UI coupling.
library;

import 'sleep_cycle_result.dart';

/// Provides sleep-cycle calculations.
///
/// Usage:
/// ```dart
/// final results = SleepCalculator.calculateWakeUpTimes(
///   bedTime: DateTime.now(),
///   fallAsleepBufferMinutes: 15,
/// );
/// ```
class SleepCalculator {
  // Private constructor — prevent instantiation.
  SleepCalculator._();

  /// Duration of a single sleep cycle.
  static const int _cycleMinutes = 90;

  /// Maximum number of cycles to compute.
  static const int _maxCycles = 6;

  /// Calculates exactly 6 wake-up options (1–6 cycles).
  ///
  /// [bedTime] — the moment the user gets into bed.
  /// [fallAsleepBufferMinutes] — estimated minutes to fall asleep (default 15).
  ///
  /// Returns a [List] of 6 [SleepCycleResult] instances ordered by cycle count.
  static List<SleepCycleResult> calculateWakeUpTimes({
    required DateTime bedTime,
    int fallAsleepBufferMinutes = 15,
  }) {
    final DateTime actualSleepTime =
        bedTime.add(Duration(minutes: fallAsleepBufferMinutes));

    return List<SleepCycleResult>.generate(_maxCycles, (index) {
      final int cycle = index + 1;
      final int totalMinutes = _cycleMinutes * cycle;
      final DateTime wakeUp =
          actualSleepTime.add(Duration(minutes: totalMinutes));

      return SleepCycleResult(
        wakeUpTime: wakeUp,
        cycleCount: cycle,
        totalDurationHours: totalMinutes / 60.0,
        moodIndicator: SleepCycleResult.moodForCycles(cycle),
      );
    });
  }
}
