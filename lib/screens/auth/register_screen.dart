// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../config/app_router.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import '../../widgets/tv_focusable_card.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill all fields');
      return;
    }
    if (password != confirm) {
      _showError('Passwords do not match');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    final cred =
        await ref.read(authNotifierProvider.notifier).register(email, password);
    if (!mounted) return;

    if (cred != null) {
      context.go(AppRoutes.profileSetup);
    } else {
      _showError('Registration failed. Email may already be in use.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.incorrect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Create Account'),
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Join Study Quest! 🚀',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your account to start learning',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _TVTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _TVTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outlined,
                  obscureText: _obscurePassword,
                ),
                const SizedBox(height: 16),
                _TVTextField(
                  controller: _confirmController,
                  label: 'Confirm Password',
                  icon: Icons.lock_outlined,
                  obscureText: _obscurePassword,
                ),
                const SizedBox(height: 32),
                TVButton(
                  label: isLoading ? 'Creating...' : 'Create Account',
                  icon: Icons.person_add_rounded,
                  autofocus: true,
                  onPressed: isLoading ? null : _register,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TVTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _TVTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          labelStyle: const TextStyle(color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}

// ── Profile Setup Screen ──────────────────────────────────────────────────

// lib/screens/auth/profile_setup_screen.dart
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  int _selectedAge = 11;
  int _selectedGrade = 5;
  String _selectedSubject = 'math';

  final _subjects = [
    {'id': 'math', 'label': 'Math', 'emoji': '🔢'},
    {'id': 'science', 'label': 'Science', 'emoji': '🔬'},
    {'id': 'english', 'label': 'English', 'emoji': '📖'},
    {'id': 'geography', 'label': 'Geography', 'emoji': '🌍'},
  ];

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    final uid = ref.read(currentUserIdProvider);
    if (uid == null) {
      if (mounted) context.go(AppRoutes.login);
      return;
    }

    // Get the current user's email from Firebase Auth
    final authUser = ref.read(authStateProvider).value;
    final email = authUser?.email ?? '';

    final user = UserModel(
      uid: uid,
      email: email,
      name: _nameController.text.trim(),
      age: _selectedAge,
      grade: _selectedGrade,
      favoriteSubject: _selectedSubject,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(userServiceProvider).createUser(user);
    } catch (e) {
      // If user doc already exists, update instead
      await ref.read(userServiceProvider).updateUser(uid, {
        'name': user.name,
        'age': user.age,
        'grade': user.grade,
        'favoriteSubject': user.favoriteSubject,
      });
    }

    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Spacing.xxl),
              child: Column(
                children: [
                  const Text('🎓', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  Text(
                    'Set Up Your Profile',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let\'s personalize your learning adventure!',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Name field
                  _TVTextField(
                    controller: _nameController,
                    label: 'Your Name',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 24),

                  // Age & Grade row
                  Row(
                    children: [
                      Expanded(
                        child: _NumberPicker(
                          label: 'Age',
                          emoji: '🎂',
                          value: _selectedAge,
                          min: 5,
                          max: 18,
                          onChanged: (v) =>
                              setState(() => _selectedAge = v),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _NumberPicker(
                          label: 'Grade',
                          emoji: '📚',
                          value: _selectedGrade,
                          min: 1,
                          max: 12,
                          onChanged: (v) =>
                              setState(() => _selectedGrade = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Favorite subject
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Favorite Subject',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: AppTheme.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: _subjects.map((s) {
                      final isSelected = _selectedSubject == s['id'];
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: TVFocusableCard(
                            onTap: () => setState(
                                () => _selectedSubject = s['id'] as String),
                            backgroundColor: isSelected
                                ? AppTheme.primary
                                : AppTheme.surfaceVariant,
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(s['emoji']!,
                                    style: const TextStyle(fontSize: 28)),
                                const SizedBox(height: 6),
                                Text(
                                  s['label']!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 40),

                  TVButton(
                    label: 'Start My Quest! 🚀',
                    autofocus: true,
                    onPressed: _saveProfile,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberPicker extends StatelessWidget {
  final String label;
  final String emoji;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _NumberPicker({
    required this.label,
    required this.emoji,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Text('$emoji  $label',
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: AppTheme.primary, size: 28),
                onPressed:
                    value > min ? () => onChanged(value - 1) : null,
              ),
              Text(
                '$value',
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: AppTheme.primary, size: 28),
                onPressed:
                    value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
