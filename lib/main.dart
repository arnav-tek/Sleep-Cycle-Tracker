import 'package:flutter/material.dart';
import 'dart:ui';

import 'luna_theme.dart';
import 'screens/mission_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/sleep_cycle_selection_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';



void main() {
  runApp(const SleepCycleApp());
}

/// Root widget.
///
/// Skill: @stitch-design — Premium aesthetic defined in .stitch/DESIGN.md.
class SleepCycleApp extends StatelessWidget {
  const SleepCycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LunaSleep',
      debugShowCheckedModeBanner: false,
      theme: LunaTheme.darkTheme,
      home: const MainScaffold(),
    );
  }
}

/// A scaffold with bottom navigation to explore the premium features.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const SleepCycleSelectionScreen(),
    const HistoryScreen(),
    const MissionScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              backgroundColor: const Color(0xFF131313).withValues(alpha: 0.75),
              selectedItemColor: LunaTheme.primary,
              unselectedItemColor: LunaTheme.onSurfaceVariant,
              selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
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
                    icon: Icon(Icons.alarm_rounded), label: 'Alarm'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.sports_esports_rounded), label: 'Wake'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings_rounded), label: 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
