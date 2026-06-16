// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_theme.dart';
import '../../config/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/tv_focusable_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _loginFocus = FocusNode();
  final _registerFocus = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _loginFocus.dispose();
    _registerFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    await ref.read(authNotifierProvider.notifier).signIn(email, password);

    if (!mounted) return;

    final state = ref.read(authNotifierProvider);
    if (state.hasError) {
      _showError('Invalid email or password');
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.incorrect,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Row(
          children: [
            // Left panel - branding
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1E30), Color(0xFF0D0F1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🎓', style: TextStyle(fontSize: 60)),
                      ),
                    ).animate().scale(
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        ),
                    const SizedBox(height: 24),
                    Text(
                      'Study Quest',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 8),
                    Text(
                      'Learn. Play. Level Up!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.primary,
                          ),
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 60),
                    ...[
                      _FeatureBadge(emoji: '🏆', label: 'Earn Achievements'),
                      _FeatureBadge(emoji: '⚡', label: 'Level Up Fast'),
                      _FeatureBadge(emoji: '🔥', label: 'Daily Streaks'),
                      _FeatureBadge(emoji: '🎯', label: 'Fun Quizzes'),
                    ].animate(interval: 100.ms).fadeIn(delay: 600.ms).slideX(begin: -0.2),
                  ],
                ),
              ),
            ),

            // Right panel - login form
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome back!',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ).animate().fadeIn(delay: 200.ms),

                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue your adventure',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ).animate().fadeIn(delay: 300.ms),

                        const SizedBox(height: 40),

                        _buildTextField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          label: 'Email',
                          hint: 'your@email.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          onSubmitted: (_) => _passwordFocus.requestFocus(),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          label: 'Password',
                          hint: '••••••••',
                          icon: Icons.lock_outlined,
                          obscureText: _obscurePassword,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppTheme.textMuted,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          onSubmitted: (_) => _login(),
                        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

                        const SizedBox(height: 32),

                        TVButton(
                          label: isLoading ? 'Signing in...' : 'Start Quest!',
                          icon: isLoading ? null : Icons.play_arrow_rounded,
                          color: AppTheme.primary,
                          focusNode: _loginFocus,
                          autofocus: true,
                          onPressed: isLoading ? null : _login,
                          width: double.infinity,
                        ).animate().fadeIn(delay: 600.ms),

                        const SizedBox(height: 16),

                        TVButton(
                          label: 'Create Account',
                          icon: Icons.person_add_outlined,
                          color: AppTheme.surfaceVariant,
                          focusNode: _registerFocus,
                          onPressed: () => context.push(AppRoutes.register),
                          width: double.infinity,
                        ).animate().fadeIn(delay: 700.ms),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
    ValueChanged<String>? onSubmitted,
  }) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasFocus
                    ? AppTheme.primary
                    : Colors.white.withOpacity(0.08),
                width: hasFocus ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              keyboardType: keyboardType,
              onSubmitted: onSubmitted,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                prefixIcon: Icon(icon, color: AppTheme.primary),
                suffixIcon: suffix,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 18),
                labelStyle:
                    const TextStyle(color: AppTheme.textSecondary),
                hintStyle: const TextStyle(color: AppTheme.textMuted),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  final String emoji;
  final String label;

  const _FeatureBadge({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
