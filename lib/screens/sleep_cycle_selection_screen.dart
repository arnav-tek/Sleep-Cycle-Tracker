import 'package:flutter/material.dart';
import '../core/sleep_calculator.dart';
import '../core/sleep_cycle_result.dart';
import '../core/app_state.dart';
import '../core/alarm_service.dart';
import '../luna_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sleep Setup — with alarm time picker, alarm status banner, and cycle suggestions.
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
  TimeOfDay _pickedTime = TimeOfDay.now();

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
      _selectedIndex = _results.length > 4 ? 4 : _results.length - 1;
    });
  }

  /// Open the system time picker and set alarm for the chosen time.
  Future<void> _openTimePicker() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _pickedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: LunaTheme.primary,
              onPrimary: Colors.white,
              surface: LunaTheme.surfaceHigh,
              onSurface: LunaTheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _pickedTime = picked);
      _setAlarmFromTimeOfDay(picked);
    }
  }

  void _setAlarmFromTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    var alarmTime = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    // If the selected time has already passed today, schedule for tomorrow
    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }
    _setAlarmAndNotify(alarmTime);
  }

  void _setAlarmFromCycle(SleepCycleResult result) {
    _setAlarmAndNotify(result.wakeUpTime);
  }

  void _setAlarmAndNotify(DateTime alarmTime) {
    AppStateManager().setAlarm(alarmTime);
    if (alarmTime.isAfter(DateTime.now())) {
      AlarmService.instance.scheduleAlarm(alarmTime);
    }
    final label = alarmTime.isAfter(DateTime.now())
        ? '🌙  Alarm set for ${_fmtDt(alarmTime)}'
        : '⏰  Time already passed — scheduled for tomorrow';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          label,
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
  }

  void _cancelAlarm() {
    AppStateManager().clearAlarm();
    AlarmService.instance.cancelAlarm();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🔕  Alarm cancelled',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: LunaTheme.surfaceHighest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStateManager(),
      builder: (context, _) {
        final state = AppStateManager();
        final activeAlarm = state.selectedAlarmTime;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────────
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
                        'Set your alarm or choose a sleep cycle',
                        style: GoogleFonts.manrope(
                          color: LunaTheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Active Alarm Banner ──────────────────────────────────────
                if (activeAlarm != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            LunaTheme.primaryDim.withValues(alpha: 0.25),
                            LunaTheme.primary.withValues(alpha: 0.10),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: LunaTheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: LunaTheme.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.alarm_on_rounded,
                                color: LunaTheme.primary, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ALARM ACTIVE',
                                  style: GoogleFonts.manrope(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: LunaTheme.primary,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _fmtDt(activeAlarm),
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: LunaTheme.onSurface,
                                    letterSpacing: -1.0,
                                  ),
                                ),
                                Text(
                                  _timeUntil(activeAlarm),
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: LunaTheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Cancel button
                          GestureDetector(
                            onTap: _cancelAlarm,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: LunaTheme.error.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded,
                                  color: LunaTheme.error, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Set Alarm Button ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: GestureDetector(
                    onTap: _openTimePicker,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: activeAlarm == null
                          ? LunaTheme.gradientButton()
                          : BoxDecoration(
                              color: LunaTheme.surfaceHigh,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: LunaTheme.outlineVariant,
                              ),
                            ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            activeAlarm == null
                                ? Icons.alarm_add_rounded
                                : Icons.edit_rounded,
                            color: activeAlarm == null
                                ? Colors.white
                                : LunaTheme.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            activeAlarm == null
                                ? 'Set Alarm Time'
                                : 'Change Alarm Time',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: activeAlarm == null
                                  ? Colors.white
                                  : LunaTheme.onSurfaceVariant,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Smart Suggestions Header ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
                  child: Text(
                    'SMART CYCLE SUGGESTIONS',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: LunaTheme.onSurfaceVariant,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                // ── Grid of cycle options ────────────────────────────────────
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final res = _results[index];
                      final isSelected = _selectedIndex == index;
                      final isRecommended = index == 4;
                      final mood = _getMoodConfig(res.moodIndicator);

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedIndex = index);
                          _setAlarmFromCycle(res);
                        },
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
                                      borderRadius:
                                          BorderRadius.circular(100),
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                                : LunaTheme
                                                    .onSurfaceVariant,
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
                                                : LunaTheme
                                                    .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Time + duration
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _fmtDt(res.wakeUpTime),
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
                                            color:
                                                LunaTheme.onSurfaceVariant,
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
        );
      },
    );
  }

  _MoodConfig _getMoodConfig(String indicator) {
    switch (indicator) {
      case 'Skull':
        return const _MoodConfig(icon: Icons.battery_alert);
      case 'Sad':
        return const _MoodConfig(icon: Icons.battery_3_bar);
      default:
        return const _MoodConfig(icon: Icons.auto_awesome);
    }
  }

  String _fmtDt(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _timeUntil(DateTime target) {
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) return 'Ringing now!';
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 0) return 'Rings in ${hours}h ${minutes}m';
    return 'Rings in ${minutes}m';
  }
}

class _MoodConfig {
  const _MoodConfig({required this.icon});

  final IconData icon;
}
