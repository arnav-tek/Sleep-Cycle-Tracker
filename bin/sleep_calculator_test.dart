/// Standalone test harness for [SleepCalculator].
///
/// Run with:
///   dart run bin/sleep_calculator_test.dart
library;

import 'package:sleep_cycle_alarm/core/sleep_calculator.dart';

void main() {
  final DateTime bedTime = DateTime.now();
  const int buffer = 15; // minutes to fall asleep

  print('=== Sleep Cycle Calculator Test ===');
  print('Bed time       : ${_fmt(bedTime)}');
  print('Fall-asleep buf: $buffer min');
  print('Actual sleep   : ${_fmt(bedTime.add(const Duration(minutes: buffer)))}');
  print('-----------------------------------');

  final results = SleepCalculator.calculateWakeUpTimes(
    bedTime: bedTime,
    fallAsleepBufferMinutes: buffer,
  );

  for (final r in results) {
    print(r);
  }

  print('===================================');
}

String _fmt(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:'
    '${dt.minute.toString().padLeft(2, '0')}';
