import 'package:flutter/material.dart';

/// Represents a completed sleep session.
class SleepRecord {
  SleepRecord({
    required this.date,
    required this.wakeUpTime,
    required this.count,
    required this.durationHours,
    required this.mood,
  });

  final DateTime date;
  final DateTime wakeUpTime;
  final int count;
  final double durationHours;
  final String mood;
}

/// Global State Manager for LunaSleep.
///
/// Uses [ValueNotifier] for simple, lightweight reactivity without
/// external dependencies.
class AppStateManager extends ChangeNotifier {
  AppStateManager._internal();
  factory AppStateManager() => _instance;

  // Singleton Pattern
  static final AppStateManager _instance = AppStateManager._internal();

  /// Currently selected alarm time.
  DateTime? _selectedAlarmTime;
  DateTime? get selectedAlarmTime => _selectedAlarmTime;

  /// User-configurable buffer for falling asleep.
  int _fallAsleepBuffer = 15;
  int get fallAsleepBuffer => _fallAsleepBuffer;

  /// Historical sleep records — starts empty, populated by real user sessions.
  final List<SleepRecord> _history = [];
  List<SleepRecord> get history => List.unmodifiable(_history);

  void setAlarm(DateTime time) {
    _selectedAlarmTime = time;
    notifyListeners();
  }

  void setBuffer(int minutes) {
    _fallAsleepBuffer = minutes;
    notifyListeners();
  }

  void addRecord(SleepRecord record) {
    _history.insert(0, record);
    notifyListeners();
  }

  /// Calculates "Sleep Quality" percentage based on cycle count.
  /// 6 cycles = 100%, 5 cycles = 85%, etc.
  int get sleepQuality {
    if (_history.isEmpty) return 0;
    final last = _history.first;
    return (last.count / 6 * 100).clamp(0, 100).toInt();
  }
}
