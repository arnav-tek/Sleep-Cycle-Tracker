# LunaSleep Project Tracker - Bugs & Missing Features

This document tracks all the known bugs, missing core functionalities, and new features to be implemented step-by-step.

## 🛠️ Missing Core Functions & Features

- [x] **Background Alarm System**: Added `AlarmService` (in-app timer) that fires the mini-game when alarm time is reached. Added `NotificationService` stub + `flutter_local_notifications` and `android_alarm_manager_plus` dependencies for future OS-level background scheduling.
- [x] **Side Panel (Drawer) Implementation**: Implemented a full navigation drawer with all 5 tabs + Sign In link. Hamburger menu icon on Dashboard now opens the drawer.
- [x] **User Authentication & Accounts**: Created a premium `AuthScreen` with email/password fields, Google & Apple social login buttons (visual), and "Continue as Guest". Accessible from the navigation drawer "Sign In" option. Firebase backend not yet wired (needs project config).
- [x] **Local Data Persistence**: Rewrote `AppStateManager` with `SharedPreferences`. All alarms, sleep history, fall-asleep buffer, volume, vibration, difficulty, and smart wind-down settings now persist to disk automatically.
- [x] **Alarm Mini-Game Intercept**: The wake-up game now launches automatically as a full-screen route when the alarm fires. After completing the 30s mission and tapping "Dismiss", it records a sleep session and pops back to the main app with a snackbar.

---

## 🐛 Code Bug Fixes

- [x] **Bottom Nav Label Mismatch**: Changed `'Alarm'` label on bottom nav index 2 to `'History'` to match the actual screen and test expectations.
- [x] **Unused Variable Warning**: Removed dangling `_ = alarm` and `final alarm = ...` in `_onAlarmDismissed`.
- [x] **Settings Not Persisting**: Settings screen (volume, vibration, difficulty, wind-down) now reads/writes through `AppStateManager` instead of ephemeral local `setState`.
- [x] **Widget Test Expectations**: Verified test matches actual nav labels (`Dash`, `Sleep`, `History`, `Wake`, `Settings`).
- [x] **Game Steering Unresponsive**: Clamped `_targetX` strictly inside `PlayerCar.setTargetX` so the car doesn't get stuck mathematically off-screen when users tap repeatedly while against the edge.
- [x] **Game Score Inflation**: Fixed points tracker in `WakeUpGame._handleCrash` to correctly reset points to 0 on crash for an accurate 30-second run tracking.
- [x] **IDE Red Errors (SDK Incompatibility)**: Bulk replaced ALL `Color.withOpacity()` calls across 10 source files with `.withValues(alpha:)`. `flutter analyze` now reports **0 issues** (previously 35 deprecation warnings).
- [x] **Hardcoded SleepRecord on Dismiss**: `_onGameComplete` previously saved static `count: 5, durationHours: 7.5` regardless of actual sleep. Now derives real `durationHours` from the stored alarm time and `fallAsleepBuffer`, calculates cycle count (`cycles = (hours / 1.5).round()`), and selects a mood label ('Happy' / 'Okay' / 'Tired') accordingly.
- [x] **Past-Alarm Silent Failure**: `scheduleAlarm` is now only called when the selected wake-up time is in the future. If the time has already passed, the alarm time is still saved to `SharedPreferences` (for in-app polling) and the user sees a clear snackbar message: "time already passed today".
- [x] **Dead `onMenuTap` Parameter**: Removed the unused `VoidCallback? onMenuTap` parameter from `DashboardScreen`. The hamburger icon correctly calls `Scaffold.of(context).openDrawer()` which walks up to `MainScaffold`'s drawer. The parameter was never passed from `_screens`.

---

## ✅ Resolved Bugs (Prior)

- [x] **Git Merge Conflicts**: Resolved all `<<<<<<< HEAD` / `=======` / `>>>>>>>` conflict markers in `README.md`. Kept the richer content.
- [x] **Remove Demo/Mock Data**: Removed both hardcoded `SleepRecord` entries from `AppStateManager._history`. App now starts with a clean, empty state on a fresh install.

---

## 📋 Remaining (Requires External Setup)

- [ ] **Firebase Auth Integration**: The `AuthScreen` UI is ready. Wire `firebase_core` + `firebase_auth` once a Firebase project is created and `google-services.json` / `GoogleService-Info.plist` are added.
- [x] **Native Background Alarms**: Dependencies added (`flutter_local_notifications`, `android_alarm_manager_plus`). Added Android manifest permissions (`SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`, `USE_FULL_SCREEN_INTENT`) for full lock-screen alarm support. iOS is not configured as this project is Android-focused.
- [x] **`flutter pub get`**: Dependencies are installed. `flutter analyze` returns 0 issues confirming all packages resolve correctly.

---

*Use this checklist to track our progress moving forward!*
