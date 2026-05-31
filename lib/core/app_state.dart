import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sleep_quality_calculator.dart';

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
  static const _kBedTime = 'bed_time';
  static const _kTimeFormat = 'time_format';

  bool _initialised = false;
  bool get isInitialised => _initialised;

  // ── State ───────────────────────────────────────────────────────────────────

  /// Currently selected alarm time.
  DateTime? _selectedAlarmTime;
  DateTime? get selectedAlarmTime => _selectedAlarmTime;

  /// The time the user went to bed (recorded when alarm is set).
  DateTime? _bedTime;
  DateTime? get bedTime => _bedTime;

  /// Whether the alarm is currently ringing (runtime-only, not persisted).
  bool _alarmIsRinging = false;
  bool get alarmIsRinging => _alarmIsRinging;

  /// User-configurable buffer for falling asleep.
  int _fallAsleepBuffer = 15;
  int get fallAsleepBuffer => _fallAsleepBuffer;

  bool _use24hFormat = false;
  bool get use24hFormat => _use24hFormat;

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

    // Bed time
    final bedStr = prefs.getString(_kBedTime);
    if (bedStr != null) {
      _bedTime = DateTime.tryParse(bedStr);
    }

    // Buffer
    _fallAsleepBuffer = prefs.getInt(_kBuffer) ?? 15;

    // Time Format
    final formatStr = prefs.getString(_kTimeFormat);
    _use24hFormat = formatStr == '24h';

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
    _bedTime = DateTime.now();
    _save();
    notifyListeners();
  }

  void clearAlarm() {
    _selectedAlarmTime = null;
    _bedTime = null;
    _save();
    notifyListeners();
  }

  /// Set the alarm ringing state (runtime only, not persisted).
  void setAlarmRinging(bool ringing) {
    _alarmIsRinging = ringing;
    notifyListeners();
  }

  void setBuffer(int buffer) {
    _fallAsleepBuffer = buffer;
    _save();
    notifyListeners();
  }

  void setUse24hFormat(bool use24h) {
    _use24hFormat = use24h;
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

  /// Sleep quality percentage based on actual sleep duration.
  /// Uses [SleepQualityCalculator] with smooth linear interpolation.
  int get sleepQuality {
    if (_history.isEmpty) return 0;
    final last = _history.first;
    return SleepQualityCalculator.calculate(last.durationHours).percentage;
  }

  /// Human-readable quality label: Poor, Fair, Good, or Optimal.
  String get sleepQualityLabel {
    if (_history.isEmpty) return '--';
    final last = _history.first;
    return SleepQualityCalculator.calculate(last.durationHours).label;
  }

  /// Formats a time according to the user's 12h/24h preference.
  String formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    if (_use24hFormat) {
      return '${hour.toString().padLeft(2, '0')}:$minute';
    } else {
      final period = hour < 12 ? 'AM' : 'PM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '$displayHour:$minute $period';
    }
  }

  // ── Persistence ─────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    if (_selectedAlarmTime != null) {
      await prefs.setString(_kAlarmTime, _selectedAlarmTime!.toIso8601String());
    } else {
      await prefs.remove(_kAlarmTime);
    }

    if (_bedTime != null) {
      await prefs.setString(_kBedTime, _bedTime!.toIso8601String());
    } else {
      await prefs.remove(_kBedTime);
    }

    await prefs.setString(_kTimeFormat, _use24hFormat ? '24h' : '12h');

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
