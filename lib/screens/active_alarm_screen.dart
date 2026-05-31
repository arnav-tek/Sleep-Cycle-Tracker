import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_state.dart';
import '../core/sleep_quality_calculator.dart';
import '../luna_theme.dart';

class ActiveAlarmScreen extends StatefulWidget {
  const ActiveAlarmScreen({
    super.key,
    required this.onPlay,
    required this.onSnooze,
  });

  final VoidCallback onPlay;
  final VoidCallback onSnooze;

  @override
  State<ActiveAlarmScreen> createState() => _ActiveAlarmScreenState();
}

class _ActiveAlarmScreenState extends State<ActiveAlarmScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.4, end: 0.7).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final state = AppStateManager();
    final is24h = state.use24hFormat;
    
    final hour = now.hour;
    final minString = now.minute.toString().padLeft(2, '0');
    final hourString = is24h
        ? hour.toString().padLeft(2, '0')
        : (hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)).toString();
    final periodString = is24h ? '' : (hour < 12 ? 'AM' : 'PM');

    return Scaffold(
      backgroundColor: LunaTheme.background,
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            top: -100,
            left: -50,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _pulseAnimation.value,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: LunaTheme.primaryDim.withValues(alpha: 0.15),
                      boxShadow: [
                        BoxShadow(
                          color: LunaTheme.primaryDim.withValues(alpha: 0.15),
                          blurRadius: 150,
                          spreadRadius: 100,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LunaTheme.tertiaryDim.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: LunaTheme.tertiaryDim.withValues(alpha: 0.1),
                    blurRadius: 150,
                    spreadRadius: 100,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Section
                  Column(
                    children: [
                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              LunaTheme.surfaceHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: LunaTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'WAKE DURING LIGHT SLEEP',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: LunaTheme.onSurfaceVariant,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Time
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: LunaTheme.primary
                                        .withValues(alpha: 0.1),
                                    blurRadius: 80,
                                    spreadRadius: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                hourString,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 110,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                  color: Colors.white,
                                ),
                              ),
                              AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, _) {
                                    return Opacity(
                                      opacity: _pulseController.value > 0.5
                                          ? 1.0
                                          : 0.2,
                                      child: Text(
                                        ':',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 110,
                                          fontWeight: FontWeight.bold,
                                          height: 1.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }),
                              Text(
                                minString,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 110,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                  color: Colors.white,
                                ),
                              ),
                              if (periodString.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: Text(
                                    periodString,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Good Morning',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: LunaTheme.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (state.selectedAlarmTime != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Alarm set for ${state.formatTime(state.selectedAlarmTime!)}',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: LunaTheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Middle Section: Metric Artifacts
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.bedtime_rounded,
                          iconColor: LunaTheme.tertiaryDim,
                          label: 'SLEEP DURATION',
                          value: _getSleepDuration(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.auto_awesome_rounded,
                          iconColor: LunaTheme.primary,
                          label: 'SLEEP QUALITY',
                          value: _getSleepQuality(),
                        ),
                      ),
                    ],
                  ),

                  // Bottom CTA
                  Column(
                    children: [
                      GestureDetector(
                        onTap: widget.onPlay,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                LunaTheme.primaryDim,
                                LunaTheme.primary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: LunaTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 40,
                                spreadRadius: 5,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_circle_filled_rounded,
                                  color: Colors.black, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                'Play to Dismiss',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.chevron_right_rounded,
                                  color: Colors.black.withValues(alpha: 0.5),
                                  size: 24),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: widget.onSnooze,
                        style: TextButton.styleFrom(
                          foregroundColor: LunaTheme.onSurfaceVariant,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'SNOOZE FOR 9 MINUTES',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSleepDuration() {
    final state = AppStateManager();
    final bedTime = state.bedTime;
    if (bedTime == null) return '-- --';

    final buffer = state.fallAsleepBuffer;
    final sleepStart = bedTime.add(Duration(minutes: buffer));
    final rawMinutes = DateTime.now().difference(sleepStart).inMinutes;
    final totalMinutes = rawMinutes.clamp(0, 720);
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String _getSleepQuality() {
    final state = AppStateManager();
    final bedTime = state.bedTime;
    if (bedTime == null) return '--';

    final buffer = state.fallAsleepBuffer;
    final sleepStart = bedTime.add(Duration(minutes: buffer));
    final rawMinutes = DateTime.now().difference(sleepStart).inMinutes;
    final durationHours = rawMinutes.clamp(0, 720) / 60.0;

    final result = SleepQualityCalculator.calculate(durationHours);
    return result.label;
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: LunaTheme.surfaceHighest.withValues(alpha: 0.4),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: LunaTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: LunaTheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
