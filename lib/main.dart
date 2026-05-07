import 'package:flutter/material.dart';
import 'dart:ui';

import 'luna_theme.dart';
import 'core/app_state.dart';
import 'core/alarm_service.dart';
import 'screens/active_alarm_screen.dart';
import 'screens/mission_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/sleep_cycle_selection_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStateManager().init();
  await AlarmService().init();
  runApp(const SleepCycleApp());
}

/// Root widget.
class SleepCycleApp extends StatelessWidget {
  const SleepCycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LunaSleep',
      debugShowCheckedModeBanner: false,
      theme: LunaTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}

/// Gates the app behind authentication.
/// Shows [AuthScreen] if the user hasn't logged in yet.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await AuthScreen.isLoggedIn();
    if (!mounted) return;
    setState(() {
      _isLoggedIn = loggedIn;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: LunaTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: LunaTheme.primary),
        ),
      );
    }

    if (!_isLoggedIn) {
      return AuthScreen(
        onAuthenticated: () => setState(() => _isLoggedIn = true),
      );
    }

    return const MainScaffold();
  }
}

/// Main scaffold with bottom navigation, side drawer, and alarm game intercept.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  bool _showGameOverlay = false;
  String _userName = 'Dreamer'; // ignore: unused_field

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const SleepCycleSelectionScreen(),
    const HistoryScreen(),
    const MissionScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Start in-app alarm polling.
    AlarmService.instance.start(onAlarmFired: _onAlarmFired);

    // Listen for background alarm events.
    AlarmService.instance.alarmFiredNotifier.addListener(_onBgAlarmFired);

    // If the alarm already fired (cold start), show game immediately.
    if (AlarmService.instance.alarmFiredNotifier.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AppStateManager().setAlarmRinging(true);
          setState(() => _showGameOverlay = true);
        }
      });
    }

    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await AuthScreen.getUserName();
    if (mounted) setState(() => _userName = name);
  }

  void _onAlarmFired() {
    if (!mounted) return;
    AppStateManager().setAlarmRinging(true);
    setState(() => _showGameOverlay = true);
  }

  void _onBgAlarmFired() {
    if (!mounted) return;
    if (AlarmService.instance.alarmFiredNotifier.value) {
      AppStateManager().setAlarmRinging(true);
      setState(() => _showGameOverlay = true);
    }
  }

  void _onGameComplete() {
    final now = DateTime.now();
    final alarm = AppStateManager().selectedAlarmTime;

    AlarmService.instance.dismiss();

    // Build a real sleep record from the alarm data.
    if (alarm != null) {
      // Estimate sleep duration: time from ~8 hours before alarm to now.
      // If the user used Sleep Setup, the alarm was set to a calculated wake time.
      // We use: duration = difference between alarm time set and 'bedtime' implied.
      // Since we don't store bedtime, approximate from alarm minus buffer.
      final buffer = AppStateManager().fallAsleepBuffer;
      final estimatedBedTime = alarm.subtract(Duration(
        minutes: buffer + (AppStateManager().difficultyIndex + 1) * 90,
      ));
      final rawHours = now.difference(estimatedBedTime).inMinutes / 60.0;
      final durationHours = rawHours.clamp(1.0, 12.0); // sanity clamp
      final cycles = (durationHours / 1.5).round().clamp(1, 6);
      final mood = cycles >= 5 ? 'Happy' : (cycles >= 3 ? 'Okay' : 'Tired');

      AppStateManager().addRecord(
        SleepRecord(
          date: now,
          wakeUpTime: now,
          count: cycles,
          durationHours: double.parse(durationHours.toStringAsFixed(1)),
          mood: mood,
        ),
      );
    }

    if (mounted) {
      AppStateManager().setAlarmRinging(false);
      setState(() => _showGameOverlay = false);
    }
  }

  @override
  void dispose() {
    AlarmService.instance.stop();
    AlarmService.instance.alarmFiredNotifier.removeListener(_onBgAlarmFired);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Main App ────────────────────────────────────────────────────
        Scaffold(
          key: _scaffoldKey,
          extendBody: true,
          backgroundColor: LunaTheme.background,

          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0E0E0E), Color(0xFF121220)],
              ),
            ),
            child: _screens[_currentIndex],
          ),

          // ── Bottom Navigation ──────────────────────────────────────────
          bottomNavigationBar: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  backgroundColor:
                      const Color(0xFF131313).withValues(alpha: 0.75),
                  selectedItemColor: LunaTheme.primary,
                  unselectedItemColor: LunaTheme.onSurfaceVariant,
                  selectedLabelStyle: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(fontSize: 10),
                  type: BottomNavigationBarType.fixed,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.dashboard_rounded), label: 'Dash'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.bedtime_rounded), label: 'Sleep'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.history_rounded), label: 'History'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.sports_esports_rounded),
                        label: 'Wake'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.settings_rounded), label: 'Settings'),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Alarm Game Overlay (Task 5) ─────────────────────────────────
        if (_showGameOverlay) _buildGameOverlay(),
      ],
    );
  }

  // ── Alarm Game Full-Screen Overlay ──────────────────────────────────────

  Widget _buildGameOverlay() {
    return Positioned.fill(
      child: Material(
        color: Colors.black,
        child: _AlarmGameIntercept(
          onDismissed: _onGameComplete,
        ),
      ),
    );
  }
}

/// Full-screen alarm intercept that sequences ActiveAlarmScreen -> MissionScreen.
/// Forces the user to complete the driving game to dismiss the alarm.
class _AlarmGameIntercept extends StatefulWidget {
  const _AlarmGameIntercept({required this.onDismissed});

  final VoidCallback onDismissed;

  @override
  State<_AlarmGameIntercept> createState() => _AlarmGameInterceptState();
}

class _AlarmGameInterceptState extends State<_AlarmGameIntercept> {
  bool _showGame = false;

  void _snooze() {
    // In a real app we'd reschedule the background alarm for 9 mins from now
    AlarmService.instance.dismiss(); // dismiss current
    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    if (_showGame) {
      return MissionScreen(
        fromAlarm: true,
        onDismissed: widget.onDismissed,
      );
    }
    return ActiveAlarmScreen(
      onPlay: () => setState(() => _showGame = true),
      onSnooze: _snooze,
    );
  }
}
