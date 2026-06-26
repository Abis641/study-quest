import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_theme.dart';
import '../../config/app_router.dart';
import '../../models/lesson_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/stats_bar.dart';
import '../../widgets/subject_card.dart';
import '../../widgets/tv_focusable_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _mathFocus = FocusNode();
  final _scienceFocus = FocusNode();
  final _englishFocus = FocusNode();
  final _geoFocus = FocusNode();
  final _achievFocus = FocusNode();
  final _missionFocus = FocusNode();
  final _profileFocus = FocusNode();

  @override
  void dispose() {
    _mathFocus.dispose();
    _scienceFocus.dispose();
    _englishFocus.dispose();
    _geoFocus.dispose();
    _achievFocus.dispose();
    _missionFocus.dispose();
    _profileFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userStreamProvider);

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.arrowUp):
            const DirectionalFocusIntent(TraversalDirection.up),
        LogicalKeySet(LogicalKeyboardKey.arrowDown):
            const DirectionalFocusIntent(TraversalDirection.down),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft):
            const DirectionalFocusIntent(TraversalDirection.left),
        LogicalKeySet(LogicalKeyboardKey.arrowRight):
            const DirectionalFocusIntent(TraversalDirection.right),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DirectionalFocusIntent: DirectionalFocusAction(),
        },
        child: Scaffold(
          backgroundColor: AppTheme.background,
          body: userAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (user) {
              if (user == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                );
              }
              return Container(
                decoration: const BoxDecoration(
                    gradient: AppTheme.backgroundGradient),
                child: Column(
                  children: [
                    _buildHeader(user),
                    const SizedBox(height: 8),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 40),
                      child: StatsBar(user: user),
                    ),
                    const SizedBox(height: 24),
                    Expanded(child: _buildGrid()),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 32, 40, 16),
      child: Row(
        children: [
          UserAvatar(
            networkUrl: user.avatarUrl,
            size: TVSizes.avatarSize,
            name: user.name,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                Text(
                  '${user.name}! 👋',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
          TVFocusableCard(
            onTap: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (mounted) context.go(AppRoutes.login);
            },
            backgroundColor: AppTheme.surfaceVariant,
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.logout_rounded,
              color: AppTheme.textSecondary,
              size: 24,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Adventure',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SubjectCard(
                subject: SubjectData.all[0],
                onTap: () =>
                    context.push('${AppRoutes.subject}/math'),
                focusNode: _mathFocus,
                autofocus: true,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              const SizedBox(width: 16),
              SubjectCard(
                subject: SubjectData.all[1],
                onTap: () =>
                    context.push('${AppRoutes.subject}/science'),
                focusNode: _scienceFocus,
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2),
              const SizedBox(width: 16),
              SubjectCard(
                subject: SubjectData.all[2],
                onTap: () =>
                    context.push('${AppRoutes.subject}/english'),
                focusNode: _englishFocus,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              const SizedBox(width: 16),
              SubjectCard(
                subject: SubjectData.all[3],
                onTap: () =>
                    context.push('${AppRoutes.subject}/geography'),
                focusNode: _geoFocus,
              ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ActionCard(
                emoji: '🏆',
                title: 'Achievements',
                subtitle: 'View your badges',
                color: AppTheme.achievementColor,
                onTap: () => context.push(AppRoutes.achievements),
                focusNode: _achievFocus,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              const SizedBox(width: 16),
              ActionCard(
                emoji: '🎯',
                title: 'Daily Missions',
                subtitle: '3 missions today',
                color: AppTheme.secondary,
                onTap: () => context.push(AppRoutes.missions),
                focusNode: _missionFocus,
              ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),
              const SizedBox(width: 16),
              ActionCard(
                emoji: '👤',
                title: 'My Profile',
                subtitle: 'View your stats',
                color: AppTheme.primary,
                onTap: () => context.push(AppRoutes.profile),
                focusNode: _profileFocus,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              const SizedBox(width: 16),
              _DailyTipCard()
                  .animate()
                  .fadeIn(delay: 450.ms)
                  .slideY(begin: 0.2),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyTipCard extends StatelessWidget {
  static const _tips = [
    '💡 Reading 20 min a day exposes you to 1.8 million words per year!',
    '🧠 Sleep helps your brain store memories — rest well!',
    '⚡ Short study sessions with breaks work better than cramming!',
    '🌟 Every expert was once a beginner. Keep practicing!',
  ];

  @override
  Widget build(BuildContext context) {
    final tip = _tips[DateTime.now().day % _tips.length];
    return TVFocusableCard(
      onTap: () {},
      width: TVSizes.cardWidth,
      height: TVSizes.cardHeight,
      backgroundColor: AppTheme.cardBase,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.tertiary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Daily Tip',
              style: TextStyle(
                color: AppTheme.tertiary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          Text(
            tip,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              height: 1.5,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
