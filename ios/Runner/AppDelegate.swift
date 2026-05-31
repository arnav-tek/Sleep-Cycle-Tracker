import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // ── Critical Alerts & Notification Setup ──────────────────────────────
    // Set the notification center delegate so alerts display in foreground.
    UNUserNotificationCenter.current().delegate = self

    // Request notification permissions including critical alerts.
    // Critical alerts bypass silent mode and DND.
    // NOTE: Requires the com.apple.developer.usernotifications.critical-alerts
    // entitlement in your Apple Developer account.
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .sound, .badge, .criticalAlert, .provisional]
    ) { granted, error in
      if let error = error {
        print("LunaSleep: Notification permission error: \(error.localizedDescription)")
      }
      print("LunaSleep: Critical alert permission granted: \(granted)")
    }

    // Register notification action categories for alarm interaction
    let playAction = UNNotificationAction(
      identifier: "PLAY_GAME",
      title: "Play to Dismiss",
      options: [.foreground]
    )
    let snoozeAction = UNNotificationAction(
      identifier: "SNOOZE",
      title: "Snooze 9 min",
      options: []
    )
    let alarmCategory = UNNotificationCategory(
      identifier: "LUNA_ALARM",
      actions: [playAction, snoozeAction],
      intentIdentifiers: [],
      options: [.customDismissAction]
    )
    UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ── Present notifications even when the app is in the foreground ──────
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.alert, .sound, .badge])
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
