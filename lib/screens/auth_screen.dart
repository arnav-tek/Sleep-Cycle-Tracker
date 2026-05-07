import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../luna_theme.dart';

/// Authentication screen — Sign Up / Log In flow.
///
/// Uses local [SharedPreferences] for demo-level persistence.
/// Swap in Firebase Auth or any provider by replacing the
/// `_submit` body with `FirebaseAuth.instance.*` calls.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onAuthenticated});

  /// Called when the user has successfully signed in or signed up.
  final VoidCallback onAuthenticated;

  static const String _kIsLoggedIn = 'is_logged_in';
  static const String _kUserName = 'user_name';
  static const String _kUserEmail = 'user_email';

  /// Check whether the user has previously authenticated.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kIsLoggedIn) ?? false;
  }

  /// Sign-out helper.
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsLoggedIn, false);
  }

  /// Read saved user name.
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserName) ?? 'Dreamer';
  }

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  // Key references from parent widget class.
  static String get _kIsLoggedIn => AuthScreen._kIsLoggedIn;
  static String get _kUserName => AuthScreen._kUserName;
  static String get _kUserEmail => AuthScreen._kUserEmail;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    _animController.reverse().then((_) {
      setState(() {
        _isLogin = !_isLogin;
        _error = null;
      });
      _animController.forward();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // ── Replace this block with Firebase Auth in production ──────────
    if (password.length < 6) {
      setState(() {
        _loading = false;
        _error = 'Password must be at least 6 characters.';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    if (_isLogin) {
      final storedEmail = prefs.getString(_kUserEmail);
      if (storedEmail == null || storedEmail != email) {
        setState(() {
          _loading = false;
          _error = 'No account found with this email. Please sign up.';
        });
        return;
      }
    } else {
      // Sign up: save user
      await prefs.setString(_kUserEmail, email);
      await prefs.setString(
        _kUserName,
        _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : email.split('@').first,
      );
    }

    await prefs.setBool(_kIsLoggedIn, true);
    // ────────────────────────────────────────────────────────────────

    if (!mounted) return;

    setState(() => _loading = false);
    widget.onAuthenticated();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LunaTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0E0E0E), Color(0xFF121220)],
          ),
        ),
        child: Stack(
          children: [
            // Ambient glow – top right
            Positioned(
              top: -120,
              right: -60,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LunaTheme.primary.withValues(alpha: 0.08),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: const SizedBox.shrink(),
                ),
              ),
            ),
            // Ambient glow – bottom left
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LunaTheme.tertiaryDim.withValues(alpha: 0.06),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: const SizedBox.shrink(),
                ),
              ),
            ),

            // ── Main content ─────────────────────────────────────────
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // Moon logo
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: LunaTheme.primary.withValues(alpha: 0.1),
                            boxShadow: [
                              BoxShadow(
                                color: LunaTheme.primary.withValues(alpha: 0.15),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.bedtime_rounded,
                            color: LunaTheme.primary,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Title
                        Text(
                          'LunaSleep',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: LunaTheme.primary,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLogin
                              ? 'Welcome back, dreamer'
                              : 'Create your sleep profile',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            color: LunaTheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ── Form ───────────────────────────────────────
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Display name (sign up only)
                              if (!_isLogin) ...[
                                _buildInputField(
                                  controller: _nameController,
                                  label: 'Display Name',
                                  icon: Icons.person_outline_rounded,
                                ),
                                const SizedBox(height: 14),
                              ],
                              _buildInputField(
                                controller: _emailController,
                                label: 'Email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Enter your email';
                                  }
                                  if (!v.contains('@')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _buildInputField(
                                controller: _passwordController,
                                label: 'Password',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: LunaTheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Enter a password';
                                  }
                                  if (v.length < 6) {
                                    return 'At least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        // Error message
                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              color: LunaTheme.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        // ── CTA ──────────────────────────────────────
                        Container(
                          width: double.infinity,
                          decoration: LunaTheme.gradientButton(),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(100),
                              onTap: _loading ? null : _submit,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                child: Center(
                                  child: _loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          _isLogin ? 'Sign In' : 'Create Account',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Divider ──────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: LunaTheme.outlineVariant,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'or',
                                style: GoogleFonts.manrope(
                                  color: LunaTheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: LunaTheme.outlineVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Social buttons (visual) ──────────────────
                        _buildSocialButton(
                          icon: Icons.g_mobiledata_rounded,
                          label: 'Continue with Google',
                        ),
                        const SizedBox(height: 12),
                        _buildSocialButton(
                          icon: Icons.apple_rounded,
                          label: 'Continue with Apple',
                        ),
                        const SizedBox(height: 24),

                        // ── Continue as Guest ────────────────────────
                        Center(
                          child: TextButton(
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool(_kIsLoggedIn, true);
                              await prefs.setString(_kUserName, 'Dreamer');
                              widget.onAuthenticated();
                            },
                            child: Text(
                              'Continue as Guest →',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: LunaTheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Toggle login / sign up ───────────────────
                        Center(
                          child: GestureDetector(
                            onTap: _toggleMode,
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  color: LunaTheme.onSurfaceVariant,
                                ),
                                children: [
                                  TextSpan(
                                    text: _isLogin
                                        ? "Don't have an account? "
                                        : 'Already have an account? ',
                                  ),
                                  TextSpan(
                                    text: _isLogin ? 'Sign Up' : 'Sign In',
                                    style: const TextStyle(
                                      color: LunaTheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.manrope(
        color: LunaTheme.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: LunaTheme.onSurfaceVariant, size: 20),
        suffixIcon: suffixIcon,
        hintText: label,
        hintStyle: GoogleFonts.manrope(
          color: LunaTheme.onSurfaceVariant.withValues(alpha: 0.5),
          fontSize: 15,
        ),
        filled: true,
        fillColor: LunaTheme.surfaceLow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: LunaTheme.primaryDim,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: LunaTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: LunaTheme.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: LunaTheme.surfaceLow,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Social auth not configured yet.',
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
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: LunaTheme.onSurface, size: 24),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: LunaTheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
