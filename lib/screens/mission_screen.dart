import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

import '../game/wake_up_game.dart';
import '../luna_theme.dart';

/// Wake-Up Challenge — aligned with Stitch reference.
/// HUD: floating TIME REMAINING + POINTS cards.
/// Controls: semi-transparent Left/Right arrow overlays.
/// Completion: minimalist alarm dismissed screen.
class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  bool _missionComplete = false;
  int _points = 0;
  double _timeDisplay = 30.0;
  late WakeUpGame _game;

  @override
  void initState() {
    super.initState();
    _game = WakeUpGame(
      onMissionComplete: _onMissionComplete,
      onTimeUpdate: _onTimeUpdate,
      onPointsUpdate: _onPointsUpdate,
    );
  }

  void _onMissionComplete() {
    if (!mounted) return;
    setState(() => _missionComplete = true);
  }

  void _onTimeUpdate(double t) {
    if (!mounted) return;
    setState(() => _timeDisplay = t);
  }

  void _onPointsUpdate(int p) {
    if (!mounted) return;
    setState(() => _points = p);
  }

  void _resetMission() {
    setState(() {
      _missionComplete = false;
      _points = 0;
      _timeDisplay = 30.0;
      _game = WakeUpGame(
        onMissionComplete: _onMissionComplete,
        onTimeUpdate: _onTimeUpdate,
        onPointsUpdate: _onPointsUpdate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_missionComplete) {
      return _buildCompletionScreen();
    }
    return _buildGameScreen();
  }

  // ─── Completion Screen ───────────────────────────────────────────────────────
  Widget _buildCompletionScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0D0D), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon glow
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LunaTheme.primary.withValues(alpha: 0.1),
                    boxShadow: [
                      BoxShadow(
                        color: LunaTheme.primary.withValues(alpha: 0.2),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.done_all_rounded,
                    color: LunaTheme.primary,
                    size: 72,
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  'Good Morning',
                  style: GoogleFonts.spaceGrotesk(
                    color: LunaTheme.onSurface,
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mission accomplished. You are awake.',
                  style: GoogleFonts.manrope(
                    color: LunaTheme.onSurfaceVariant,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                // Stats chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatChip(
                      icon: Icons.stars_rounded,
                      label: 'Points',
                      value: '$_points',
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      icon: Icons.timer_rounded,
                      label: 'Survived',
                      value: '30s',
                    ),
                  ],
                ),
                const SizedBox(height: 56),
                // CTA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    decoration: LunaTheme.gradientButton(),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: _resetMission,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh_rounded,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Dismiss',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: LunaTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: LunaTheme.primary, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: LunaTheme.onSurface)),
          Text(label,
              style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: LunaTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ─── Game Screen ────────────────────────────────────────────────────────────
  Widget _buildGameScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Game canvas ──────────────────────────────────────────────────
            GameWidget(game: _game),

            // ── HUD: TIME + POINTS (top row) ─────────────────────────────────
            Positioned(
              top: 16,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Expanded(
                    child: _buildHudCard(
                      label: 'TIME REMAINING',
                      value: '${_timeDisplay.toStringAsFixed(1)}s',
                      color: LunaTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildHudCard(
                      label: 'POINTS',
                      value: '$_points',
                      color: LunaTheme.tertiaryDim,
                    ),
                  ),
                ],
              ),
            ),

            // ── Left control overlay ─────────────────────────────────────────
            Positioned(
              left: 0,
              top: 100,
              bottom: 100,
              width: MediaQuery.of(context).size.width * 0.4,
              child: GestureDetector(
                onTap: () => _game.tapLeft(),
                behavior: HitTestBehavior.translucent,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white.withValues(alpha: 0.25),
                    size: 56,
                  ),
                ),
              ),
            ),

            // ── Right control overlay ────────────────────────────────────────
            Positioned(
              right: 0,
              top: 100,
              bottom: 100,
              width: MediaQuery.of(context).size.width * 0.4,
              child: GestureDetector(
                onTap: () => _game.tapRight(),
                behavior: HitTestBehavior.translucent,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.white.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.25),
                    size: 56,
                  ),
                ),
              ),
            ),

            // ── Bottom instruction chip ──────────────────────────────────────
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: LunaTheme.surfaceContainer.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.touch_app_rounded,
                            color: LunaTheme.primary, size: 16),
                        const SizedBox(width: 10),
                        Text(
                          'Tap sides to steer • Survive 30 seconds',
                          style: GoogleFonts.manrope(
                            color: LunaTheme.onSurfaceVariant,
                            fontSize: 13,
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

  Widget _buildHudCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: LunaTheme.surfaceContainer.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: LunaTheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
