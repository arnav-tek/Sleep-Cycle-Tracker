import 'package:flutter/material.dart';
import 'screens/mission_screen.dart';
import 'core/sleep_calculator.dart';
import 'core/sleep_cycle_result.dart';
import 'dart:ui';

void main() {
  runApp(const SleepCycleApp());
}

/// Root widget.
///
/// Skill: @frontend-design — establishes global #121212 dark theme and neon accents.
/// Skill: @flutter-expert — sets up Material 3 properly.
class SleepCycleApp extends StatelessWidget {
  const SleepCycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Cycle Alarm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D), // Deeper black
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFB026FF),
          surface: Color(0xFF1E1E1E),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      home: const DemoHomeScreen(),
    );
  }
}

/// A simple demo screen that calculates sleep cycles and provides
/// a button to trigger the alarm dismissal mini-game.
class DemoHomeScreen extends StatefulWidget {
  const DemoHomeScreen({super.key});

  @override
  State<DemoHomeScreen> createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends State<DemoHomeScreen> {
  List<SleepCycleResult> _results = [];
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    setState(() {
      _results = SleepCalculator.calculateWakeUpTimes(
        bedTime: DateTime.now(),
        fallAsleepBufferMinutes: 15,
      );
      // Auto-select optimal (usually the last 5 or 6 cycles)
      _selectedIndex = 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedResult =
        _selectedIndex != null ? _results[_selectedIndex!] : null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D0D0D),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF131313),
              Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background ambient glow
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFB026FF).withValues(alpha: 0.05),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 30, 28, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Night',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.2,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sleep cycles calculated based on now',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final res = _results[index];
                        final isSelected = _selectedIndex == index;
                        final isOptimal = res.cycleCount >= 5;

                        // Refined mood config
                        final moodConfig = _getMoodConfig(res.moodIndicator);

                        return AnimatedScale(
                          scale: isSelected ? 1.025 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedIndex = index),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.white.withValues(alpha: 0.04),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFB026FF)
                                                .withValues(alpha: 0.6)
                                            : Colors.white.withValues(alpha: 0.08),
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFFB026FF)
                                                    .withValues(alpha: 0.15),
                                                blurRadius: 20,
                                                spreadRadius: 2,
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        // Dynamic status icon
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color:
                                                moodConfig.color.withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            moodConfig.icon,
                                            color: moodConfig.color,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (isOptimal && index == 5)
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      bottom: 4),
                                                  child: Text(
                                                    'RECOMMENDED FOR YOU',
                                                    style: const TextStyle(
                                                      color: Color(0xFFB026FF),
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w900,
                                                      letterSpacing: 0.8,
                                                    ),
                                                  ),
                                                ),
                                              Text(
                                                _fmt(res.wakeUpTime),
                                                style: const TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: -0.5,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${res.cycleCount} Cycles • ${res.totalDurationHours}h sleep',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.5),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFB026FF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.check,
                                                color: Colors.white, size: 16),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Sticky Bottom CTA
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 34),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color(0xFF0D0D0D),
                      const Color(0xFF0D0D0D).withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB026FF).withValues(alpha: 0.3),
                              blurRadius: 25,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MissionScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB026FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 22),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            selectedResult != null
                                ? 'Set Alarm for ${_fmt(selectedResult.wakeUpTime)}'
                                : 'Select a time',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _recalculate,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withValues(alpha: 0.4),
                      ),
                      child: const Text(
                        'Recalculate times',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _MoodConfig _getMoodConfig(String indicator) {
    switch (indicator) {
      case 'Skull':
        return const _MoodConfig(
          icon: Icons.battery_alert_rounded,
          color: Colors.grey,
        );
      case 'Sad':
        return const _MoodConfig(
          icon: Icons.battery_3_bar_rounded,
          color: Colors.lightBlueAccent,
        );
      case 'Happy':
      default:
        return const _MoodConfig(
          icon: Icons.auto_awesome_rounded,
          color: Color(0xFFB026FF),
        );
    }
  }

  String _fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _MoodConfig {
  const _MoodConfig({required this.icon, required this.color});
  final IconData icon;
  final Color color;
}
