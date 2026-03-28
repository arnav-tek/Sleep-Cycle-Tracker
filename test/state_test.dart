import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_cycle_alarm/core/app_state.dart';

void main() {
  group('AppStateManager Tests', () {
    late AppStateManager state;

    setUp(() {
      state = AppStateManager();
      // Reset state properties manually if needed,
      // but singleton remains. Clear specific fields for tests.
      state.setAlarm(DateTime(2026, 3, 24, 7, 0));
    });

    test('Initial selected alarm time is correct', () {
      expect(state.selectedAlarmTime?.hour, 7);
      expect(state.selectedAlarmTime?.minute, 0);
    });

    test('Updating alarm time notifies listeners', () {
      bool notified = false;
      state.addListener(() => notified = true);

      final newTime = DateTime(2026, 3, 24, 8, 30);
      state.setAlarm(newTime);

      expect(state.selectedAlarmTime, newTime);
      expect(notified, isTrue);
    });

    test('Updating fall asleep buffer notifies listeners', () {
      bool notified = false;
      state.addListener(() => notified = true);

      state.setBuffer(25);

      expect(state.fallAsleepBuffer, 25);
      expect(notified, isTrue);
    });

    test('Adding a record updates history and notifies listeners', () {
      bool notified = false;
      state.addListener(() => notified = true);

      final initialCount = state.history.length;
      final record = SleepRecord(
        date: DateTime.now(),
        wakeUpTime: DateTime.now().add(const Duration(hours: 8)),
        count: 6,
        durationHours: 9.0,
        mood: 'Happy',
      );

      state.addRecord(record);

      expect(state.history.length, initialCount + 1);
      expect(state.history.first, record);
      expect(notified, isTrue);
    });

    test('Sleep quality calculation matches cycle count', () {
      final record = SleepRecord(
        date: DateTime.now(),
        wakeUpTime: DateTime.now(),
        count: 6,
        durationHours: 9.0,
        mood: 'Happy',
      );
      state.addRecord(record);
      expect(state.sleepQuality, 100);

      final lowRecord = SleepRecord(
        date: DateTime.now(),
        wakeUpTime: DateTime.now(),
        count: 3,
        durationHours: 4.5,
        mood: 'Sad',
      );
      state.addRecord(lowRecord);
      expect(state.sleepQuality, 50);
    });
  });
}
