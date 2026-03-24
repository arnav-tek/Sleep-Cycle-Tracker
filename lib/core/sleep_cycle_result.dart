/// Data model representing a single sleep cycle result.
///
/// Skill: @architecture — clean, reusable data model with no UI coupling.
///
/// Each result contains:
/// - The calculated [wakeUpTime] for a specific cycle count.
/// - The [cycleCount] (1–6 full 90-minute cycles).
/// - The [totalDurationHours] of sleep.
/// - A [moodIndicator] string reflecting expected restfulness.
library;

/// Immutable data class for one sleep-cycle option.
class SleepCycleResult {
  /// Creates a [SleepCycleResult].
  const SleepCycleResult({
    required this.wakeUpTime,
    required this.cycleCount,
    required this.totalDurationHours,
    required this.moodIndicator,
  });

  /// The exact time the alarm should ring.
  final DateTime wakeUpTime;

  /// Number of completed 90-minute cycles (1–6).
  final int cycleCount;

  /// Total sleep duration in fractional hours (e.g. 1.5, 3.0).
  final double totalDurationHours;

  /// Qualitative mood prediction:
  /// - `"Skull"` for 1–2 cycles (severely under-rested)
  /// - `"Sad"`   for 3–4 cycles (moderate rest)
  /// - `"Happy"` for 5–6 cycles (well-rested)
  final String moodIndicator;

  /// Derives the appropriate [moodIndicator] for a given [cycleCount].
  static String moodForCycles(int cycleCount) {
    if (cycleCount <= 2) return 'Skull';
    if (cycleCount <= 4) return 'Sad';
    return 'Happy';
  }

  @override
  String toString() =>
      'Cycle $cycleCount | ${totalDurationHours}h | '
      'Wake @ ${_fmt(wakeUpTime)} | Mood: $moodIndicator';

  /// Minimal HH:mm formatter (avoids `intl` dependency for a utility model).
  static String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}
