# 🌙 LunaSleep: Cycle Alarm & Space Shooter Mini-Game

A premium, production-ready Flutter application designed to optimize your wake-up routine. Calculate the perfect time to wake up based on 90-minute sleep cycles and dismiss your alarm with a forgiving Space Shooter challenge built on the Flame engine. Features full native background alarm support!

---

## 🚀 Key Features

*   **Mathematical Sleep Engine**: Calculates exactly 6 wake-up windows based on your bedtime, optimized for REM cycles, tracking true sleep duration and quality.
*   **Flame Mini-Game**: Play a forgiving Space Shooter mission to dismiss the alarm—score 50 points to prove you're awake!
*   **Native Background Alarms**: Utilizes full-screen intent on Android and Critical Alerts on iOS to guarantee your alarm fires even when the app is killed or the phone is on silent.
*   **Premium Aesthetics**: A dark mode (#0E0E0E) interface with glassmorphism, glowing neon accents, and fluid animations.
*   **Dynamic Customization**: Includes a 12h/24h toggle that updates the entire app reactively.

---

## 🛠️ Stack & Technologies

*   **Language**: [Dart](https://dart.dev/)
*   **Framework**: [Flutter](https://flutter.dev/) (Material 3)
*   **Game Engine**: [Flame Engine](https://flame-engine.org/)
*   **State Management**: Native `ChangeNotifier` and `ListenableBuilder` for reactive, performant UI logic.
*   **Native Integration**: `android_alarm_manager_plus` & `flutter_local_notifications`.

---

## 🎮 How to Play (Alarm Mission)

1.  **Select a Time**: Pick one of the calculated sleep cycles.
2.  **Survive & Shoot**: Once the alarm triggers, drag your glowing spaceship left and right to avoid asteroids while automatically shooting them.
3.  **Score Points**: Destroy 5 asteroids (10 pts each) to reach the 50 point goal.
4.  **Forgiving Mechanics**: You have 30 seconds and 3 lives. Run out of time? The timer just resets. Lose all lives? They instantly regenerate. 
5.  **Wake Up**: Complete the mission to successfully dismiss the alarm, or use the handy 9-minute Snooze overlay if you need more rest.

---

## 📦 Installation & Setup

1.  Clone the repository.
2.  Ensure you have Flutter installed.
3.  Run `flutter pub get`.
4.  Launch the app:
    ```bash
    flutter run -d chrome  # For Web
    flutter run            # For Mobile/Desktop
    ```

---

*Built with ❤️ by Antigravity AI*
