import 'package:flutter/material.dart';
import 'dart:ui';
import '../core/app_state.dart';
import '../luna_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dashboard — aligned with Stitch "Celestial Guardian" design.
/// Layout: Hero alarm time → Sleep Quality card → Stats grid → 3-Day Mood Trend.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStateManager(),
      builder: (context, _) {
        final state = AppStateManager();
        final nextAlarm = state.selectedAlarmTime;
        final quality = state.sleepQuality;
        final history = state.history;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Ambient purple nebula glow — top right
              Positioned(
                top: -80,
                right: -80,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LunaTheme.primary.withValues(alpha: 0.08),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: const SizedBox.shrink(),
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Top Bar ──────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.menu_rounded,
                              color: LunaTheme.onSurfaceVariant),
                          Text(
                            'LunaSleep',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: LunaTheme.primary,
                              letterSpacing: -0.8,
                            ),
                          ),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                LunaTheme.surfaceHighest.withValues(alpha: 0.7),
                            child: const Icon(Icons.person_outline_rounded,
                                color: LunaTheme.onSurfaceVariant, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 44),

                      // ── Hero: Next Alarm ──────────────────────────────────
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'NEXT ALARM',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: LunaTheme.onSurfaceVariant,
                                letterSpacing: 2.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  LunaTheme.ctaGradient.createShader(bounds),
                              child: Text(
                                nextAlarm != null
                                    ? _formatTime(nextAlarm)
                                    : '--:--',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 88,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -5.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: LunaTheme.surfaceHighest
                                    .withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.alarm_rounded,
                                      size: 14,
                                      color: LunaTheme.tertiaryDim),
                                  const SizedBox(width: 8),
                                  Text(
                                    nextAlarm != null
                                        ? '${_getDayName(nextAlarm.weekday)} ${nextAlarm.hour < 12 ? "Morning" : "Evening"}'
                                        : 'No alarm set',
                                    style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: LunaTheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // ── Sleep Quality Card ────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: LunaTheme.glassDecoration(opacity: 0.06),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sleep Quality',
                                      style: GoogleFonts.manrope(
                                        color: LunaTheme.onSurfaceVariant,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      quality >= 80 ? 'Great' : 'Good',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                        color: LunaTheme.onSurface,
                                        letterSpacing: -1.5,
                                      ),
                                    ),
                                  ],
                                ),
                                _buildProgressCircle(quality),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              quality >= 80
                                  ? 'You slept ${_computeExtraHours(history)} longer than your average.'
                                  : 'Try for one more cycle tonight for peak recovery.',
                              style: GoogleFonts.manrope(
                                color: LunaTheme.onSurfaceVariant,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Stats Grid ────────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'Optimal Wake',
                              value: nextAlarm != null
                                  ? _formatTime(nextAlarm)
                                  : '--:--',
                              subtitle: 'Based on REM cycle',
                              color: LunaTheme.tertiaryDim,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Avg. Sleep',
                              value: _computeAvgSleep(history),
                              subtitle: 'Last 7 days',
                              color: LunaTheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── 3-Day Mood Trend ──────────────────────────────────
                      _buildStatCard(
                        title: '3-Day Mood Trend',
                        value: '',
                        subtitle: '',
                        child: SizedBox(
                          height: 110,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: _buildThreeDayTrend(history),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _getDayName(int weekday) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[weekday - 1];
  }

  String _computeAvgSleep(List<SleepRecord> history) {
    if (history.isEmpty) return '--';
    final total = history.fold<double>(0, (s, r) => s + r.durationHours);
    return '${(total / history.length).toStringAsFixed(1)}h';
  }

  String _computeExtraHours(List<SleepRecord> history) {
    if (history.length < 2) return '1.2 hours';
    final diff = history.first.durationHours -
        (history.skip(1).fold<double>(0, (s, r) => s + r.durationHours) /
            (history.length - 1));
    if (diff <= 0) return '0.5 hours';
    return '${diff.abs().toStringAsFixed(1)} hours';
  }

  List<Widget> _buildThreeDayTrend(List<SleepRecord> history) {
    final now = DateTime.now();
    return List.generate(3, (i) {
      final offset = 2 - i;
      final day = now.subtract(Duration(days: offset));
      final dayLabel = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
          [day.weekday - 1];
      final record = history.where((r) =>
          r.date.year == day.year &&
          r.date.month == day.month &&
          r.date.day == day.day).toList();
      final hasData = record.isNotEmpty;
      final factor =
          hasData ? (record.first.durationHours / 9.0).clamp(0.15, 1.0) : 0.2;
      final isToday = offset == 0;
      final color = isToday
          ? LunaTheme.primary
          : (hasData ? LunaTheme.tertiaryDim : LunaTheme.onSurfaceVariant);
      final icon = isToday
          ? Icons.auto_awesome
          : (hasData ? Icons.battery_3_bar : Icons.remove);

      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(icon, size: 15, color: color.withValues(alpha: 0.9)),
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 64 * factor,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isToday ? 0.3 : 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dayLabel,
            style: GoogleFonts.manrope(
              fontSize: 10,
              color: LunaTheme.onSurfaceVariant,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      );
    });
  }

  // ─── Sub-widgets ─────────────────────────────────────────────────────────────

  Widget _buildProgressCircle(int value) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(
            value: value / 100,
            strokeWidth: 6,
            strokeCap: StrokeCap.round,
            valueColor: const AlwaysStoppedAnimation<Color>(LunaTheme.primary),
            backgroundColor: LunaTheme.surfaceHighest,
          ),
        ),
        Text(
          '$value%',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: LunaTheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    Color? color,
    Widget? child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: LunaTheme.surfaceCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.manrope(
              color: LunaTheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          if (value.isNotEmpty)
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: color ?? LunaTheme.onSurface,
              ),
            ),
          if (child != null) child,
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.manrope(
                color: LunaTheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
