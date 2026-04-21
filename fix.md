# LunaSleep Project Tracker - Bugs & Missing Features

This document tracks all the known bugs, missing core functionalities, and new features to be implemented step-by-step.

## 🛠️ Missing Core Functions & Features

- [ ] **Background Alarm System**: The app currently doesn't trigger alarms in the OS background. We need to implement proper background scheduling (using packages like `android_alarm_manager_plus` and `flutter_local_notifications`) so alarms ring even when the app is closed.
- [ ] **Side Panel (Drawer) Implementation**: The side panel navigation is completely unhooked. It needs to be wired up or created so users can access extra menus.
- [ ] **User Authentication & Accounts**: There is no way for users to create an account or log in. We need to add an authentication flow (Sign Up / Log In page) and integrate an auth provider (like Firebase Auth).
- [ ] **Local Data Persistence**: Settings, alarms, and sleep history are deleted every time the app closes. We must implement a real local database (like `hive`, `sqflite`, or `shared_preferences`) so user data is saved permanently on the device.
- [ ] **Alarm Mini-Game Intercept**: Right now, the "survive to wake" driving game is just a static tab at the bottom of the screen. It needs to be organically triggered to pop up over the lock screen the exact moment the alarm rings.

---

## ✅ Resolved Bugs

- [x] **Git Merge Conflicts**: Resolved all `<<<<<<< HEAD` / `=======` / `>>>>>>>` conflict markers in `README.md`. Kept the richer content.
- [x] **Remove Demo/Mock Data**: Removed both hardcoded `SleepRecord` entries from `AppStateManager._history`. App now starts with a clean, empty state on a fresh install.

---

*Use this checklist to track our progress moving forward!*
