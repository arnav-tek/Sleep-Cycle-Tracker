import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_state.dart';

/// Alarm scheduling & firing service.
///
/// Combines:
///  • **In-app polling** — checks every second while the app is open.
///  • **Background scheduling** — uses [AndroidAlarmManager] so the alarm
///    fires even when the app is killed.
///  • **Notifications** — full-screen intent notification wakes the user.
class AlarmService {
  AlarmService._();

  // Allow `AlarmService()` for backwards-compat with existing main.dart call.
  factory AlarmService() => instance;

  static final AlarmService instance = AlarmService._();

  // ── Constants ────────────────────────────────────────────────────────────
  static const int _bgAlarmId = 42;
  static const String _portName = 'luna_alarm_port';
  static const String _kAlarmFired = 'alarm_fired';

  // ── Notification plugin ──────────────────────────────────────────────────
  final FlutterLocalNotificationsPlugin _notif =
      FlutterLocalNotificationsPlugin();

  // ── In-app polling state ─────────────────────────────────────────────────
  Timer? _timer;
  VoidCallback? _onAlarmFired;

  /// Whether the alarm has fired and is waiting to be dismissed.
  bool _alarmActive = false;
  bool get alarmActive => _alarmActive;

  /// ValueNotifier used by MainScaffold to react to background alarms.
  final ValueNotifier<bool> alarmFiredNotifier = ValueNotifier(false);

  bool _initialised = false;

  // ── Initialisation ───────────────────────────────────────────────────────

  /// Initialise background alarm scheduling + notifications.
  /// Call once in `main()` before `runApp`.
  Future<void> init() async {
    if (_initialised) return;

    // ── Notifications ──────────────────────────────────────────────────────
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _notif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (_) {
        alarmFiredNotifier.value = true;
      },
    );

    // ── Android Alarm Manager ──────────────────────────────────────────────
    await AndroidAlarmManager.initialize();

    // ── Isolate port for background → UI communication ─────────────────────
    final port = ReceivePort();
    IsolateNameServer.removePortNameMapping(_portName);
    IsolateNameServer.registerPortWithName(port.sendPort, _portName);

    port.listen((_) {
      _alarmActive = true;
      alarmFiredNotifier.value = true;
      _onAlarmFired?.call();
    });

    // Check if an alarm fired while the app was killed.
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kAlarmFired) == true) {
      await prefs.setBool(_kAlarmFired, false);
      _alarmActive = true;
      alarmFiredNotifier.value = true;
    }

    _initialised = true;
  }

  // ── In-app polling ───────────────────────────────────────────────────────

  /// Start checking every second while the app is foregrounded.
  void start({required VoidCallback onAlarmFired}) {
    _onAlarmFired = onAlarmFired;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _check());
  }

  /// Stop polling. Call from `dispose`.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _check() {
    if (_alarmActive) return;

    final alarm = AppStateManager().selectedAlarmTime;
    if (alarm == null) return;

    final now = DateTime.now();
    if (now.isAfter(alarm) || now.difference(alarm).abs().inSeconds < 2) {
      _alarmActive = true;
      alarmFiredNotifier.value = true;
      _onAlarmFired?.call();
    }
  }

  // ── Background scheduling ────────────────────────────────────────────────

  /// Schedule an exact background alarm for [when].
  Future<void> scheduleAlarm(DateTime when) async {
    if (!_initialised) return;

    await AndroidAlarmManager.cancel(_bgAlarmId);
    await AndroidAlarmManager.oneShotAt(
      when,
      _bgAlarmId,
      _alarmCallback,
      alarmClock: true,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  /// Cancel any pending background alarm.
  Future<void> cancelAlarm() async {
    await AndroidAlarmManager.cancel(_bgAlarmId);
  }

  // ── Dismissal ────────────────────────────────────────────────────────────

  /// Called after the user completes the wake-up mission.
  void dismiss() {
    _alarmActive = false;
    alarmFiredNotifier.value = false;
    AppStateManager().clearAlarm();
    _notif.cancelAll();
  }

  // ── Background Callback ──────────────────────────────────────────────────

  @pragma('vm:entry-point')
  static Future<void> _alarmCallback() async {
    // Persist a flag so the UI picks it up even on cold start.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAlarmFired, true);

    // Notify the running UI isolate (if alive).
    final sendPort = IsolateNameServer.lookupPortByName(_portName);
    sendPort?.send(null);

    // Fire a high-priority notification.
    final notif = FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await notif.initialize(initSettings);

    const androidDetails = AndroidNotificationDetails(
      'luna_alarm_channel',
      'LunaSleep Alarms',
      channelDescription: 'Wake-up alarm notifications',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      playSound: true,
      enableVibration: true,
    );
    const details = NotificationDetails(android: androidDetails);

    await notif.show(
      _bgAlarmId,
      '⏰ Wake Up!',
      'Survive the mission to dismiss your alarm.',
      details,
    );
  }
}
