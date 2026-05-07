import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a completed sleep session.
class SleepRecord {
  SleepRecord({
    required this.date,
    required this.wakeUpTime,
    required this.count,
    required this.durationHours,
    required this.mood,
  });

  /// Deserialize from JSON map.
  factory SleepRecord.fromJson(Map<String, dynamic> json) => SleepRecord(
        date: DateTime.parse(json['date'] as String),
        wakeUpTime: DateTime.parse(json['wakeUpTime'] as String),
        count: json['count'] as int,
        durationHours: (json['durationHours'] as num).toDouble(),
        mood: json['mood'] as String,
      );

  final DateTime date;
  final DateTime wakeUpTime;
  final int count;
  final double durationHours;
  final String mood;

  /// Serialize to JSON map.
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'wakeUpTime': wakeUpTime.toIso8601String(),
        'count': count,
        'durationHours': durationHours,
        'mood': mood,
      };
}

/// Global State Manager for LunaSleep.
///
/// Singleton with [ChangeNotifier] for lightweight reactivity.
/// Persists all state to [SharedPreferences] automatically.
class AppStateManager extends ChangeNotifier {
  AppStateManager._internal();
  factory AppStateManager() => _instance;

  // Singleton
  static final AppStateManager _instance = AppStateManager._internal();

  // ── Keys ────────────────────────────────────────────────────────────────────
  static const _kAlarmTime = 'alarm_time';
  static const _kBuffer = 'fall_asleep_buffer';
  static const _kHistory = 'sleep_history';
  static const _kVolume = 'volume';
  static const _kVibration = 'vibration_enabled';
  static const _kDifficulty = 'difficulty_index';
  static const _kSmartWindDown = 'smart_wind_down';

  bool _initialised = false;
  bool get isInitialised => _initialised;

  // ── State ───────────────────────────────────────────────────────────────────

  /// Currently selected alarm time.
  DateTime? _selectedAlarmTime;
  DateTime? get selectedAlarmTime => _selectedAlarmTime;

  /// Whether the alarm is currently ringing (runtime-only, not persisted).
  bool _alarmIsRinging = false;
  bool get alarmIsRinging => _alarmIsRinging;

  /// User-configurable buffer for falling asleep.
  int _fallAsleepBuffer = 15;
  int get fallAsleepBuffer => _fallAsleepBuffer;

  /// Historical sleep records.
  final List<SleepRecord> _history = [];
  List<SleepRecord> get history => List.unmodifiable(_history);

  /// Settings state — exposed so SettingsScreen can read/write them.
  double _volume = 0.7;
  double get volume => _volume;

  bool _vibrationEnabled = true;
  bool get vibrationEnabled => _vibrationEnabled;

  int _difficultyIndex = 1;
  int get difficultyIndex => _difficultyIndex;

  bool _smartWindDown = true;
  bool get smartWindDown => _smartWindDown;

  // ── Init ────────────────────────────────────────────────────────────────────

  /// Must be called once at app startup before `runApp`.
  Future<void> init() async {
    if (_initialised) return;

    final prefs = await SharedPreferences.getInstance();

    // Alarm time
    final alarmStr = prefs.getString(_kAlarmTime);
    if (alarmStr != null) {
      _selectedAlarmTime = DateTime.tryParse(alarmStr);
    }

    // Buffer
    _fallAsleepBuffer = prefs.getInt(_kBuffer) ?? 15;

    // History
    final historyJson = prefs.getString(_kHistory);
    if (historyJson != null) {
      final list = jsonDecode(historyJson) as List;
      _history.clear();
      _history.addAll(
        list.map((e) => SleepRecord.fromJson(e as Map<String, dynamic>)),
      );
    }

    // Settings
    _volume = prefs.getDouble(_kVolume) ?? 0.7;
    _vibrationEnabled = prefs.getBool(_kVibration) ?? true;
    _difficultyIndex = prefs.getInt(_kDifficulty) ?? 1;
    _smartWindDown = prefs.getBool(_kSmartWindDown) ?? true;

    _initialised = true;
    notifyListeners();
  }

  // ── Mutations ───────────────────────────────────────────────────────────────

  void setAlarm(DateTime time) {
    _selectedAlarmTime = time;
    _save();
    notifyListeners();
  }

  void clearAlarm() {
    _selectedAlarmTime = null;
    _save();
    notifyListeners();
  }

  /// Set the alarm ringing state (runtime only, not persisted).
  void setAlarmRinging(bool ringing) {
    _alarmIsRinging = ringing;
    notifyListeners();
  }

  void setBuffer(int minutes) {
    _fallAsleepBuffer = minutes;
    _save();
    notifyListeners();
  }

  void addRecord(SleepRecord record) {
    _history.insert(0, record);
    _save();
    notifyListeners();
  }

  void setVolume(double v) {
    _volume = v;
    _save();
    notifyListeners();
  }

  void setVibration(bool v) {
    _vibrationEnabled = v;
    _save();
    notifyListeners();
  }

  void setDifficulty(int idx) {
    _difficultyIndex = idx;
    _save();
    notifyListeners();
  }

  void setSmartWindDown(bool v) {
    _smartWindDown = v;
    _save();
    notifyListeners();
  }

  /// Calculates "Sleep Quality" percentage based on cycle count.
  /// 6 cycles = 100 %, 5 cycles = 85 %, etc.
  int get sleepQuality {
    if (_history.isEmpty) return 0;
    final last = _history.first;
    return (last.count / 6 * 100).clamp(0, 100).toInt();
  }

  // ── Persistence ─────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    if (_selectedAlarmTime != null) {
      await prefs.setString(_kAlarmTime, _selectedAlarmTime!.toIso8601String());
    } else {
      await prefs.remove(_kAlarmTime);
    }

    await prefs.setInt(_kBuffer, _fallAsleepBuffer);

    final historyJson =
        jsonEncode(_history.map((r) => r.toJson()).toList());
    await prefs.setString(_kHistory, historyJson);

    await prefs.setDouble(_kVolume, _volume);
    await prefs.setBool(_kVibration, _vibrationEnabled);
    await prefs.setInt(_kDifficulty, _difficultyIndex);
    await prefs.setBool(_kSmartWindDown, _smartWindDown);
  }
}
