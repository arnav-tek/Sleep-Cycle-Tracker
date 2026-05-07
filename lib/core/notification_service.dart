import 'package:flutter/foundation.dart';

/// Stub service for OS-level background alarm notifications.
///
/// Full implementation requires:
///   1. flutter_local_notifications plugin initialisation
///   2. android_alarm_manager_plus for exact Android alarms
///   3. AndroidManifest.xml permissions:
///      - RECEIVE_BOOT_COMPLETED
///      - SCHEDULE_EXACT_ALARM
///      - USE_FULL_SCREEN_INTENT
///   4. iOS Info.plist — UIBackgroundModes: audio, fetch
///
/// The dependencies are already in pubspec.yaml.
/// Wire this up once Flutter SDK is available for native testing.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  bool _initialised = false;

  /// Initialise the notification plugin. Call once at app startup.
  Future<void> init() async {
    if (_initialised) return;

    // TODO: Initialise flutter_local_notifications here.
    // final flnp = FlutterLocalNotificationsPlugin();
    // const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    // const iosSettings = DarwinInitializationSettings();
    // await flnp.initialize(InitializationSettings(android: androidSettings, iOS: iosSettings));

    _initialised = true;
    debugPrint('[NotificationService] Initialised (stub).');
  }

  /// Schedule an OS-level alarm at [time].
  Future<void> scheduleAlarm(DateTime time) async {
    // TODO: Use AndroidAlarmManager.oneShot or flutterLocalNotificationsPlugin
    // to schedule a full-screen intent alarm.
    debugPrint('[NotificationService] scheduleAlarm at $time (stub).');
  }

  /// Cancel any pending alarm.
  Future<void> cancelAlarm() async {
    debugPrint('[NotificationService] cancelAlarm (stub).');
  }
}
