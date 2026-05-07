import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_state.dart';
import '../game/wake_up_game.dart';
import '../luna_theme.dart';

/// Wake-Up Challenge — aligned with Stitch reference.
/// HUD: floating TIME REMAINING + POINTS cards.
/// Controls: semi-transparent Left/Right arrow overlays.
/// Completion: minimalist alarm dismissed screen.
///
/// Game is LOCKED unless the alarm is actively ringing.
class MissionScreen extends StatefulWidget {
  const MissionScreen({
    super.key,
    this.fromAlarm = false,
    this.onDismissed,
  });

  /// When true, the screen was launched by the alarm service.
  final bool fromAlarm;

  /// Called when the user dismisses the alarm after completing the mission.
  final VoidCallback? onDismissed;

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  bool _missionComplete = false;
  int _points = 0;
  double _timeDisplay = 30.0;
  double _maxTime = 30.0;
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
    setState(() {
      _timeDisplay = t;
      if (t > _maxTime) _maxTime = t;
    });
  }

  void _onPointsUpdate(int p) {
    if (!mounted) return;
    setState(() => _points = p);
  }

  void _dismissAlarm() {
    widget.onDismissed?.call();
  }

  @override
  Widget build(BuildContext context) {
    // ── GATE: If not launched from alarm, check if alarm is ringing ──
    if (!widget.fromAlarm) {
      return ListenableBuilder(
        listenable: AppStateManager(),
        builder: (context, _) {
          final isRinging = AppStateManager().alarmIsRinging;
          if (!isRinging) {
            return _buildLockedScreen();
          }
          // If alarm is ringing from bottom nav, show the game
          return _buildActiveContent();
        },
      );
    }

    return _buildActiveContent();
  }

  Widget _buildActiveContent() {
    if (_missionComplete) {
      return _buildCompletionScreen();
    }
    return _buildGameScreen();
  }

  // ─── Locked Screen (no alarm set/ringing) ───────────────────────────────────
  Widget _buildLockedScreen() {
    return Scaffold(
      backgroundColor: LunaTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lock Icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: LunaTheme.surfaceHighest.withValues(alpha: 0.5),
                      ),
                    ),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: LunaTheme.surfaceHigh,
                        border: Border.all(
                          color: LunaTheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 40,
                        color: LunaTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                Text(
                  'Wake-Up Challenge',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: LunaTheme.onSurface,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This game activates when your alarm rings.\nSet an alarm from the Sleep tab to get started.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    color: LunaTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Visual hint
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: LunaTheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: LunaTheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bedtime_rounded,
                          size: 16, color: LunaTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Go to Sleep tab',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: LunaTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 14, color: LunaTheme.primary),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // How it works
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: LunaTheme.surfaceCard(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HOW IT WORKS',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: LunaTheme.onSurfaceVariant,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStep('1', 'Set an alarm from the Sleep tab'),
                      const SizedBox(height: 8),
                      _buildStep('2', 'When alarm rings, game activates'),
                      const SizedBox(height: 8),
                      _buildStep('3', 'Survive 30s to dismiss the alarm'),
                      const SizedBox(height: 8),
                      _buildStep('4', 'Crash = +10s penalty time'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: LunaTheme.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: LunaTheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: LunaTheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Completion Screen ───────────────────────────────────────────────────────
  Widget _buildCompletionScreen() {
    final now = DateTime.now();
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final dateString =
        '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    String greeting;
    if (now.hour < 12) {
      greeting = 'Good Morning!';
    } else if (now.hour < 17) {
      greeting = 'Good Afternoon!';
    } else {
      greeting = 'Good Evening!';
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.bottomCenter,
            radius: 1.5,
            colors: [
              Color(0xFF2A1B4E), // Primary-dim derived for the center
              Color(0xFF0E0E0E),
            ],
            stops: [0.0, 0.7],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Central Sunrise/Moon Icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: LunaTheme.primary.withValues(alpha: 0.2),
                          boxShadow: [
                            BoxShadow(
                              color: LunaTheme.primary.withValues(alpha: 0.2),
                              blurRadius: 50,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        now.hour < 17
                            ? Icons.wb_twilight_rounded
                            : Icons.bedtime_rounded,
                        color: const Color(0xFFFFB347),
                        size: 96,
                        shadows: const [
                          Shadow(
                            color: Color(0x80FFB347),
                            blurRadius: 40,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Greeting Group
                  Text(
                    greeting,
                    style: GoogleFonts.spaceGrotesk(
                      color: LunaTheme.onSurface,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dateString,
                    style: GoogleFonts.manrope(
                      color: LunaTheme.onSurfaceVariant,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Success badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 16, color: Color(0xFF00E676)),
                        const SizedBox(width: 8),
                        Text(
                          'Challenge Complete — $_points pts',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF00E676),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Prompt
                  Text(
                    'Are you awake?',
                    style: GoogleFonts.manrope(
                      color: LunaTheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Primary CTA — Stop Alarm / I'm Awake
                  GestureDetector(
                    onTap: _dismissAlarm,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [LunaTheme.primaryDim, LunaTheme.primary],
                        ),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: LunaTheme.primary.withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.alarm_off_rounded,
                              color: Colors.white, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            widget.fromAlarm
                                ? '🔔 Stop Alarm'
                                : "I'm Awake!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Game Screen ────────────────────────────────────────────────────────────
  Widget _buildGameScreen() {
    final displayMinutes = (_timeDisplay / 60).floor();
    final displaySeconds = _timeDisplay.ceil() % 60;
    final timeStr = '${displayMinutes.toString().padLeft(2, '0')}:${displaySeconds.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Game canvas ──────────────────────────────────────────────────
            GameWidget(game: _game),

            // ── HUD: TIME + POINTS & Instructions (top) ──────────────────────
            Positioned(
              top: 16,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color:
                              LunaTheme.surfaceHighest.withValues(alpha: 0.4),
                          border: Border.all(
                            color:
                                LunaTheme.outlineVariant.withValues(alpha: 0.1),
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TIME REMAINING',
                                  style: GoogleFonts.manrope(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: LunaTheme.onSurfaceVariant,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  timeStr,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: _timeDisplay > 30
                                        ? LunaTheme.error
                                        : LunaTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'POINTS',
                                  style: GoogleFonts.manrope(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: LunaTheme.onSurfaceVariant,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$_points',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: LunaTheme.tertiaryDim,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: LunaTheme.background.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      _timeDisplay > 30
                          ? '⚠️ +10s penalty! Survive ${_timeDisplay.ceil()}s to dismiss'
                          : 'Keep driving for ${_timeDisplay.ceil()}s to dismiss alarm',
                      style: GoogleFonts.manrope(
                        color: _timeDisplay > 30
                            ? LunaTheme.error
                            : LunaTheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 200,
                    height: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: _timeDisplay <= 0
                            ? 1.0
                            : (1.0 - (_timeDisplay / _maxTime)).clamp(0.0, 1.0),
                        backgroundColor: LunaTheme.surfaceHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _timeDisplay > 30
                              ? LunaTheme.error
                              : LunaTheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Controls & Speedometer (Bottom) ─────────────────────────────
            Positioned(
              bottom: 32,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Control Arrow
                  GestureDetector(
                    onTap: () => _game.tapLeft(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color:
                                LunaTheme.surfaceHighest.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: LunaTheme.onSurface,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Speed Display
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value:
                                0.65, // Arbitrary visual fill mimicking gauge
                            strokeWidth: 6,
                            backgroundColor: LunaTheme.surfaceHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                LunaTheme.primary),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '82',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: LunaTheme.onSurface,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              'KM/H',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: LunaTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right Control Arrow
                  GestureDetector(
                    onTap: () => _game.tapRight(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color:
                                LunaTheme.surfaceHighest.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: LunaTheme.onSurface,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
