import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_state.dart';
import '../luna_theme.dart';
import '../main.dart';
import 'auth_screen.dart';

/// Settings — aligned with Stitch reference.
/// Now reads/writes all settings through [AppStateManager] for persistence.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppStateManager _state = AppStateManager();

  final List<String> _difficulties = ['Zen', 'Adept', 'Master'];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title ──────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                    child: Text(
                      'Settings',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 36,
                        color: LunaTheme.onSurface,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.8,
                      ),
                    ),
                  ),

                  // ── Sound & Alarm ─────────────────────────────────────────
                  _sectionLabel('Morning Routine'),
                  _buildCard(
                    children: [
                      // Volume slider
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: LunaTheme.surfaceHighest,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.volume_up_rounded,
                                color: LunaTheme.primary, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Alarm Volume',
                                      style: GoogleFonts.manrope(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: LunaTheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      '${(_state.volume * 100).toInt()}%',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: LunaTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 3,
                                    thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 8),
                                    overlayShape: const RoundSliderOverlayShape(
                                        overlayRadius: 16),
                                    activeTrackColor: LunaTheme.primary,
                                    inactiveTrackColor: LunaTheme.surfaceHighest,
                                    thumbColor: LunaTheme.primary,
                                    overlayColor:
                                        LunaTheme.primary.withValues(alpha: 0.15),
                                  ),
                                  child: Slider(
                                    value: _state.volume,
                                    onChanged: (v) => _state.setVolume(v),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      _dividerSpace(),
                      // Vibration toggle
                      _buildToggleRow(
                        icon: Icons.vibration_rounded,
                        title: 'Vibration',
                        subtitle: 'Haptic pulse on alarm',
                        value: _state.vibrationEnabled,
                        onChanged: (v) => _state.setVibration(v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Wake-Up Challenge ─────────────────────────────────────
                  _sectionLabel('Wake-Up Challenge'),
                  _buildCard(
                    children: [
                      // Difficulty segmented control
                      Text(
                        'Difficulty',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: LunaTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: LunaTheme.background,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          children: List.generate(_difficulties.length, (i) {
                            final isActive = _state.difficultyIndex == i;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => _state.setDifficulty(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: isActive
                                      ? BoxDecoration(
                                          gradient: LunaTheme.ctaGradient,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        )
                                      : BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                  child: Center(
                                    child: Text(
                                      _difficulties[i],
                                      style: GoogleFonts.manrope(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isActive
                                            ? Colors.white
                                            : LunaTheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      _dividerSpace(),
                      _buildInfoRow(
                        icon: Icons.timer_outlined,
                        title: 'Survival Time',
                        value: '30 seconds',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Sleep Preferences ────────────────────────────────────
                  _sectionLabel('Sleeping Habit'),
                  _buildCard(
                    children: [
                      _buildTapRow(
                        icon: Icons.timer_outlined,
                        title: 'Fall Asleep Buffer',
                        value: '${_state.fallAsleepBuffer} min',
                        onTap: () {
                          final next = _state.fallAsleepBuffer == 15
                              ? 20
                              : (_state.fallAsleepBuffer == 20 ? 25 : 15);
                          _state.setBuffer(next);
                        },
                      ),
                      _dividerSpace(),
                      _buildToggleRow(
                        icon: Icons.auto_awesome_rounded,
                        title: 'Smart Wind-down',
                        subtitle: 'Gradual screen dimming',
                        value: _state.smartWindDown,
                        onChanged: (v) => _state.setSmartWindDown(v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Preferences ──────────────────────────────────────────
                  _sectionLabel('Preferences'),
                  _buildCard(
                    children: [
                      _buildInfoRow(
                        icon: Icons.palette_outlined,
                        title: 'Theme',
                        value: 'Deep Space',
                      ),
                      _dividerSpace(),
                      _buildInfoRow(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        value: 'English',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Account ──────────────────────────────────────────────
                  _sectionLabel('Account'),
                  _buildCard(
                    children: [
                      _buildTapRow(
                        icon: Icons.logout_rounded,
                        title: 'Sign Out',
                        value: '',
                        onTap: () async {
                          await AuthScreen.signOut();
                          if (!context.mounted) return;
                          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const AuthGate(),
                            ),
                            (_) => false,
                          );
                        },
                        iconColor: LunaTheme.error,
                        isDestructive: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 10),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: LunaTheme.primary.withValues(alpha: 0.8),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: LunaTheme.surfaceCard(radius: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _dividerSpace() => const SizedBox(height: 20);

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: LunaTheme.surfaceHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: LunaTheme.onSurface,
                  )),
              Text(subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: LunaTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  )),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: LunaTheme.primary,
          activeTrackColor: LunaTheme.primaryDim.withValues(alpha: 0.4),
          inactiveThumbColor: LunaTheme.onSurfaceVariant,
          inactiveTrackColor: LunaTheme.surfaceHighest,
        ),
      ],
    );
  }

  Widget _buildTapRow({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    Color? iconColor,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDestructive
                  ? LunaTheme.error.withValues(alpha: 0.1)
                  : LunaTheme.surfaceHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDestructive ? LunaTheme.error : LunaTheme.onSurface,
                )),
          ),
          if (value.isNotEmpty)
            Text(value,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: LunaTheme.primary,
                  fontWeight: FontWeight.w700,
                )),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded,
              color: LunaTheme.onSurfaceVariant, size: 18),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: LunaTheme.surfaceHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(title,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: LunaTheme.onSurface,
              )),
        ),
        Text(value,
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: LunaTheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }
}
