import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../game/wake_up_game.dart';

/// The Flutter UI wrapping the Flame game.
///
/// Skill: @frontend-design — dark theme (#121212) matching game background,
/// neon purple accents, minimal distraction.
/// Skill: @flutter-expert — clean StatefulWidget managing game state properly.
class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  bool _missionComplete = false;

  void _onMissionComplete() {
    setState(() {
      _missionComplete = true;
    });
    // In a real app, stop alarm audio here.
  }

  @override
  Widget build(BuildContext context) {
    if (_missionComplete) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0D0D0D), Color(0xFF1A1A2E)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFB026FF).withValues(alpha: 0.1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB026FF).withValues(alpha: 0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.done_all_rounded,
                    color: Color(0xFFB026FF),
                    size: 80,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Good Morning',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mission accomplished. You are awake.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 64),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB026FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 12,
                      shadowColor: const Color(0xFFB026FF).withValues(alpha: 0.5),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Active Mission
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget(
              game: WakeUpGame(onMissionComplete: _onMissionComplete),
            ),
            // Optional: minimal overlay instructions
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          color: const Color(0xFFB026FF).withValues(alpha: 0.7),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Tap sides to steer. Survive 30s.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
