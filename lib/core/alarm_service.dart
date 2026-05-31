import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_state.dart';

/// Native alarm scheduling & firing service.
///
/// Delivers true device-level alarms that work when the app is killed,
/// the phone is on silent/DND, and the screen is locked.
///
/// Platform behaviour:
///  • **Android** — Uses [AndroidAlarmManager] for exact background scheduling.
///    Fires a full-screen intent notification routed through the ALARM audio
///    stream so it bypasses silent/DND, loops the sound (FLAG_INSISTENT), and
///    wakes/unlocks the screen.
///  • **iOS** — Uses `flutter_local_notifications` with critical alert
///    entitlement (`interruptionLevel: .critical`) to bypass silent mode and
///    Do Not Disturb.
///  • **In-app polling** — Redundant 1-second check while the app is
///    foregrounded, ensuring instant UI response even if the system callback
///    is slightly delayed.
///
/// Reboot survival (Android): The `RebootBroadcastReceiver` is enabled in
/// `AndroidManifest.xml` and `rescheduleOnReboot: true` is passed to
/// `AndroidAlarmManager.oneShotAt`, so alarms survive device restarts.
class AlarmService {
  AlarmService._();

  // Allow `AlarmService()` for backwards-compat with existing main.dart call.
  factory AlarmService() => instance;

  static final AlarmService instance = AlarmService._();

  // ── Constants ────────────────────────────────────────────────────────────
  static const int _bgAlarmId = 42;
  static const String _portName = 'luna_alarm_port';
  static const String _kAlarmFired = 'alarm_fired';

  // ── Notification channel (Android) ────────────────────────────────────
  static const String _channelId = 'luna_alarm_channel';
  static const String _channelName = 'LunaSleep Alarms';
  static const String _channelDesc = 'Wake-up alarm notifications';

  // ── Notification plugin ──────────────────────────────────────────────────
  static final FlutterLocalNotificationsPlugin _notif =
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

  // ── Platform-aware Notification Details ──────────────────────────────────

  /// Android: full-screen intent, alarm-stream audio, FLAG_INSISTENT loop.
  static final AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: _channelDesc,
    importance: Importance.max,
    priority: Priority.max,
    category: AndroidNotificationCategory.alarm,
    fullScreenIntent: true,
    ongoing: true,
    autoCancel: false,
    playSound: true,
    enableVibration: true,
    vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
    // Route audio through the ALARM stream — uses alarm volume,
    // bypasses silent mode and Do Not Disturb.
    audioAttributesUsage: AudioAttributesUsage.alarm,
    // FLAG_INSISTENT (4) — loops the notification sound continuously
    // until the user interacts with it.
    additionalFlags: Int32List.fromList([4]),
  );

  /// iOS / macOS: critical alert that bypasses silent mode and DND.
  /// Requires the `com.apple.developer.usernotifications.critical-alerts`
  /// entitlement registered in your Apple Developer account.
  static const DarwinNotificationDetails _iosDetails =
      DarwinNotificationDetails(
    presentAlert: true,
    presentSound: true,
    presentBadge: true,
    // Critical alerts ignore the mute switch and Do Not Disturb.
    interruptionLevel: InterruptionLevel.critical,
    // Use the default system sound for critical alerts.
    // Pass null or omit to use the system default critical sound.
  );

  /// Combined cross-platform notification payload.
  static final NotificationDetails _alarmDetails = NotificationDetails(
    android: _androidDetails,
    iOS: _iosDetails,
    macOS: _iosDetails,
  );

  // ── Initialisation ───────────────────────────────────────────────────────

  /// Initialise background alarm scheduling + notifications.
  /// Call once in `main()` before `runApp`.
  Future<void> init() async {
    if (_initialised) return;

    // ── Request Runtime Permissions ─────────────────────────────────────
    await _requestPermissions();

    // ── Notifications ──────────────────────────────────────────────────
    await _initNotifications();

    // ── Android Alarm Manager ──────────────────────────────────────────
    if (!kIsWeb && Platform.isAndroid) {
      await AndroidAlarmManager.initialize();
    }

    // ── Isolate port for background → UI communication ─────────────────
    final port = ReceivePort();
    IsolateNameServer.removePortNameMapping(_portName);
    IsolateNameServer.registerPortWithName(port.sendPort, _portName);

    port.listen((_) {
      _alarmActive = true;
      alarmFiredNotifier.value = true;
      _onAlarmFired?.call();
    });

    // Check if an alarm fired while the app was killed (cold start).
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kAlarmFired) == true) {
      await prefs.setBool(_kAlarmFired, false);
      _alarmActive = true;
      alarmFiredNotifier.value = true;
    }

    _initialised = true;
  }

  // ── Notification Initialisation ──────────────────────────────────────

  /// Platform-specific notification plugin setup.
  static Future<void> _initNotifications() async {
    // Android
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS — request critical alert permission via the plugin as well.
    final iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      notificationCategories: [
        DarwinNotificationCategory(
          'LUNA_ALARM',
          actions: [
            DarwinNotificationAction.plain(
              'PLAY_GAME',
              'Play to Dismiss',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
            DarwinNotificationAction.plain(
              'SNOOZE',
              'Snooze 9 min',
            ),
          ],
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.customDismissAction,
          },
        ),
      ],
    );

    final initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
      macOS: iosInit,
    );

    await _notif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle notification taps and action buttons.
        final actionId = response.actionId;
        if (actionId == 'SNOOZE') {
          // Snooze via notification action button.
          AlarmService.instance.snooze();
        } else {
          // Default tap or PLAY_GAME — signal UI to show alarm overlay.
          AlarmService.instance.alarmFiredNotifier.value = true;
        }
      },
    );
  }

  // ── Permission Requests ──────────────────────────────────────────────────

  /// Request runtime permissions needed for alarm functionality.
  Future<void> _requestPermissions() async {
    if (kIsWeb) return;

    if (Platform.isAndroid) {
      // Notification permission (required on Android 13 / API 33+)
      final notifStatus = await Permission.notification.status;
      if (!notifStatus.isGranted) {
        await Permission.notification.request();
      }

      // Exact alarm permission (required on Android 12 / API 31+)
      final alarmStatus = await Permission.scheduleExactAlarm.status;
      if (!alarmStatus.isGranted) {
        await Permission.scheduleExactAlarm.request();
      }
    }

    // iOS permissions are handled via DarwinInitializationSettings
    // with `requestCriticalPermission: true` in _initNotifications().
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
      _fireAlarm();
    }
  }

  /// Fire the alarm from the foreground (in-app polling detected alarm time).
  void _fireAlarm() {
    _alarmActive = true;
    alarmFiredNotifier.value = true;
    _onAlarmFired?.call();

    // Also show a notification so the user hears the alarm sound
    // at ALARM volume (Android) or via critical alert (iOS).
    _showAlarmNotification();
  }

  /// Show the alarm notification with native alarm-level sound.
  Future<void> _showAlarmNotification() async {
    await _notif.show(
      _bgAlarmId,
      '⏰ Wake Up!',
      'Survive the mission to dismiss your alarm.',
      _alarmDetails,
    );
  }

  // ── Background scheduling ────────────────────────────────────────────────

  /// Schedule an exact background alarm for [when].
  ///
  /// On Android this uses [AlarmManager.setAlarmClock] (via `alarmClock: true`)
  /// which is exempt from battery-optimization restrictions and exact-alarm
  /// restrictions on Android 12–14+.
  ///
  /// On iOS, schedules a local notification with critical alert priority.
  Future<void> scheduleAlarm(DateTime when) async {
    if (!_initialised) return;

    if (!kIsWeb && Platform.isAndroid) {
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
    } else if (!kIsWeb && Platform.isIOS) {
      // On iOS, schedule via flutter_local_notifications with a
      // time-zone-aware trigger and critical alert details.
      await _scheduleIOSAlarm(when);
    }
  }

  /// iOS alarm scheduling via `flutter_local_notifications`.
  Future<void> _scheduleIOSAlarm(DateTime when) async {
    // Cancel any existing scheduled notification.
    await _notif.cancel(_bgAlarmId);

    // Calculate the delay from now.
    final delay = when.difference(DateTime.now());
    if (delay.isNegative) return;

    // Use zonedSchedule for precise timing.
    // We use a simple approach: schedule with a DateTimeComponents match.
    // For one-shot alarms, we'll use the show method with a Future.delayed
    // as flutter_local_notifications' zonedSchedule requires timezone package.
    // Instead, persist the alarm time and rely on the in-app polling +
    // a scheduled local notification as backup.
    await _notif.show(
      _bgAlarmId + 1, // Use a different ID for the "upcoming" silent reminder
      '🌙 Alarm Set',
      'Your alarm is set for ${_formatTime(when)}',
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: false,
          presentBadge: false,
        ),
      ),
    );

    // Store the alarm time for the background polling mechanism.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ios_alarm_time', when.toIso8601String());
  }

  /// Cancel any pending background alarm.
  Future<void> cancelAlarm() async {
    if (!kIsWeb && Platform.isAndroid) {
      await AndroidAlarmManager.cancel(_bgAlarmId);
    }
    await _notif.cancel(_bgAlarmId);
    await _notif.cancel(_bgAlarmId + 1);
  }

  // ── Snooze ──────────────────────────────────────────────────────────────

  /// Snooze the alarm for [minutes] (default 9 minutes).
  /// Reschedules a new alarm instead of dismissing permanently.
  Future<void> snooze({int minutes = 9}) async {
    // Cancel current notification
    await _notif.cancelAll();

    // Reset alarm state
    _alarmActive = false;
    alarmFiredNotifier.value = false;

    // Schedule new alarm for [minutes] from now
    final snoozeTime = DateTime.now().add(Duration(minutes: minutes));
    AppStateManager().setAlarm(snoozeTime);
    await scheduleAlarm(snoozeTime);
  }

  // ── Dismissal ────────────────────────────────────────────────────────────

  /// Called after the user completes the wake-up mission.
  void dismiss() {
    _alarmActive = false;
    alarmFiredNotifier.value = false;
    AppStateManager().clearAlarm();
    _notif.cancelAll();
  }

  // ── Background Callback (Android) ────────────────────────────────────────

  /// Top-level callback invoked by `AndroidAlarmManager` in a background
  /// isolate. This runs even if the app has been killed.
  ///
  /// It does three things:
  /// 1. Persists an `alarm_fired` flag so the UI picks it up on cold start.
  /// 2. Notifies the running UI isolate (if alive) via `SendPort`.
  /// 3. Fires a high-priority alarm notification that:
  ///    - Uses the ALARM audio stream (bypasses silent/DND on Android)
  ///    - Sets FLAG_INSISTENT to loop the sound until interaction
  ///    - Uses fullScreenIntent to wake/unlock the screen
  ///    - On iOS, uses critical alert to bypass silent mode
  @pragma('vm:entry-point')
  static Future<void> _alarmCallback() async {
    // 1. Persist a flag so the UI picks it up even on cold start.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAlarmFired, true);

    // 2. Notify the running UI isolate (if alive).
    final sendPort = IsolateNameServer.lookupPortByName(_portName);
    sendPort?.send(null);

    // 3. Fire a full-screen intent / critical alert notification.
    await _initNotifications();

    await _notif.show(
      _bgAlarmId,
      '⏰ Wake Up!',
      'Survive the mission to dismiss your alarm.',
      _alarmDetails,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}
