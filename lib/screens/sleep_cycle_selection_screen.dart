import 'package:flutter/material.dart';
import '../core/sleep_calculator.dart';
import '../core/sleep_cycle_result.dart';
import '../core/app_state.dart';
import '../luna_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sleep Setup — aligned with Stitch reference.
/// Grid layout of wake-up time cards with RECOMMENDED badge on 5-cycle option.
/// Full-width gradient CTA at the bottom confirms the alarm.
class SleepCycleSelectionScreen extends StatefulWidget {
  const SleepCycleSelectionScreen({super.key});

  @override
  State<SleepCycleSelectionScreen> createState() =>
      _SleepCycleSelectionScreenState();
}

class _SleepCycleSelectionScreenState
    extends State<SleepCycleSelectionScreen> {
  List<SleepCycleResult> _results = [];
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    final state = AppStateManager();
    setState(() {
      _results = SleepCalculator.calculateWakeUpTimes(
        bedTime: DateTime.now(),
        fallAsleepBufferMinutes: state.fallAsleepBuffer,
      );
      // Default: 5 cycles (index 4) — optimal per sleep science
      _selectedIndex = _results.length > 4 ? 4 : _results.length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected =
        _selectedIndex != null ? _results[_selectedIndex!] : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sleep Setup',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 36,
                      color: LunaTheme.onSurface,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose your wake-up time based on sleep cycles',
                    style: GoogleFonts.manrope(
                      color: LunaTheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ── Selected time callout ────────────────────────────────────────
            if (selected != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: LunaTheme.glassDecoration(opacity: 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WAKE UP',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: LunaTheme.onSurfaceVariant,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ShaderMask(
                            shaderCallback: (b) =>
                                LunaTheme.ctaGradient.createShader(b),
                            child: Text(
                              _fmt(selected.wakeUpTime),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 52,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -3.0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Circadian Alignment',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                color: LunaTheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Setting your wake-up for ${_fmt(selected.wakeUpTime)} aligns with your natural ${selected.cycleCount}th sleep cycle, ensuring you feel energized.',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: LunaTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // ── Grid of options ──────────────────────────────────────────────
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final res = _results[index];
                  final isSelected = _selectedIndex == index;
                  final isRecommended = index == 4; // 5 cycles
                  final mood = _getMoodConfig(res.moodIndicator);

                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: isSelected
                          ? LunaTheme.activeCard()
                          : LunaTheme.surfaceCard(),
                      child: Stack(
                        children: [
                          // RECOMMENDED badge
                          if (isRecommended)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  gradient: LunaTheme.ctaGradient,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  'BEST',
                                  style: GoogleFonts.manrope(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          // Card content
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Icon + cycles
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? LunaTheme.primary
                                                .withValues(alpha: 0.15)
                                            : LunaTheme.surfaceHighest,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        mood.icon,
                                        size: 18,
                                        color: isSelected
                                            ? LunaTheme.primary
                                            : LunaTheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${res.cycleCount}×',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? LunaTheme.primary
                                            : LunaTheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                // Time + duration
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _fmt(res.wakeUpTime),
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected
                                            ? LunaTheme.onSurface
                                            : LunaTheme.onSurface
                                                .withValues(alpha: 0.8),
                                        letterSpacing: -1.0,
                                      ),
                                    ),
                                    Text(
                                      '${res.totalDurationHours}h sleep',
                                      style: GoogleFonts.manrope(
                                        color: LunaTheme.onSurfaceVariant,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Selected check overlay
                          if (isSelected)
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: LunaTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded,
                                    size: 12, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // ── Gradient CTA ────────────────────────────────────────────────────────
      floatingActionButton: selected == null ? null : _buildCTA(selected),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCTA(SleepCycleResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 52),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            LunaTheme.background,
            LunaTheme.background.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Container(
        decoration: LunaTheme.gradientButton(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () {
              AppStateManager().setAlarm(result.wakeUpTime);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '🌙  Alarm set for ${_fmt(result.wakeUpTime)}',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: LunaTheme.primaryDim,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Set Alarm for ${_fmt(result.wakeUpTime)}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _MoodConfig _getMoodConfig(String indicator) {
    switch (indicator) {
      case 'Skull':
        return const _MoodConfig(
            icon: Icons.battery_alert, color: LunaTheme.onSurfaceVariant);
      case 'Sad':
        return const _MoodConfig(
            icon: Icons.battery_3_bar, color: LunaTheme.tertiaryDim);
      default:
        return const _MoodConfig(
            icon: Icons.auto_awesome, color: LunaTheme.primary);
    }
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _MoodConfig {
  const _MoodConfig({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}
