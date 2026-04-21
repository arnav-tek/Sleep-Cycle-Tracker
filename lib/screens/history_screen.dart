import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../luna_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// A Premium History Screen showing past sleep sessions.
/// Now reactive — updates automatically when new records are added.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateManager();

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final history = state.history;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 30, 28, 20),
                  child: Text(
                    'History',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 40,
                        color: LunaTheme.onSurface,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -2.0),
                  ),
                ),
                Expanded(
                  child: history.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final record = history[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(24),
                              decoration: LunaTheme.surfaceCard(),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${record.date.day} ${_getMonth(record.date.month)}',
                                        style: GoogleFonts.manrope(
                                            color: LunaTheme.onSurfaceVariant,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Woke at ${_format(record.wakeUpTime)}',
                                        style: GoogleFonts.spaceGrotesk(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: LunaTheme.onSurface),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('${record.durationHours}h',
                                          style: GoogleFonts.spaceGrotesk(
                                              fontSize: 18,
                                              color: LunaTheme.primary,
                                              fontWeight: FontWeight.bold)),
                                      Text('${record.count} Cycles',
                                          style: GoogleFonts.manrope(
                                              color:
                                                  LunaTheme.onSurfaceVariant,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bedtime_outlined,
              size: 64,
              color: LunaTheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'No sleep sessions yet',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: LunaTheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set your first alarm to start tracking your sleep cycles.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: LunaTheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _format(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  String _getMonth(int m) => [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m - 1];
}
