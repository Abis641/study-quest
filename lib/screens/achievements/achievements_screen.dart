// lib/screens/achievements/achievements_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_theme.dart';
import '../../models/lesson_model.dart';
import '../../providers/user_provider.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/tv_focusable_card.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(40, 32, 40, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF9F1C), Color(0xFFFFD166)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  TVFocusableCard(
                    onTap: () => Navigator.of(context).pop(),
                    backgroundColor: Colors.white.withOpacity(0.15),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 20),
                  const Text('🏆', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Achievements',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800),
                      ),
                      if (user != null)
                        Text(
                          '${user.name}\'s Collection',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 16),
                        ),
                    ],
                  ),
                  const Spacer(),
                  if (user != null)
                    UserAvatar(
                      networkUrl: user.avatarUrl,
                      localAvatarPath: user.localAvatarPath,
                      size: 64,
                      name: user.name,
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: achievementsAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.achievementColor)),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (achievements) {
                  final unlocked =
                      achievements.where((a) => a.isUnlocked).length;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress summary
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBase,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.06)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$unlocked / ${achievements.length} Unlocked',
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: achievements.isNotEmpty
                                            ? unlocked /
                                                achievements.length
                                            : 0,
                                        backgroundColor:
                                            AppTheme.textMuted
                                                .withOpacity(0.3),
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                                AppTheme.achievementColor),
                                        minHeight: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                '🏆',
                                style: const TextStyle(fontSize: 48),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        Text(
                          'Your Badges',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),

                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children:
                              achievements.asMap().entries.map((entry) {
                            final i = entry.key;
                            final achievement = entry.value;
                            return _AchievementBadge(
                              achievement: achievement,
                            )
                                .animate()
                                .fadeIn(delay: (i * 60).ms)
                                .scale(
                                  begin: const Offset(0.8, 0.8),
                                  end: const Offset(1, 1),
                                  delay: (i * 60).ms,
                                  duration: 300.ms,
                                );
                          }).toList(),
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
  }
}

class _AchievementBadge extends StatelessWidget {
  final AchievementModel achievement;

  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;

    return TVFocusableCard(
      onTap: () => _showDetail(context),
      width: 200,
      backgroundColor: isUnlocked
          ? AppTheme.cardBase
          : AppTheme.surfaceVariant.withOpacity(0.5),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppTheme.achievementColor.withOpacity(0.15)
                      : AppTheme.textMuted.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    achievement.emoji,
                    style: TextStyle(
                      fontSize: 36,
                      color: isUnlocked ? null : Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
              if (!isUnlocked)
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.background.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: AppTheme.textMuted, size: 28),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            achievement.title,
            style: TextStyle(
              color: isUnlocked
                  ? AppTheme.textPrimary
                  : AppTheme.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          if (isUnlocked && achievement.unlockedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              _formatDate(achievement.unlockedAt!),
              style: const TextStyle(
                color: AppTheme.achievementColor,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(achievement.emoji,
                  style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                achievement.title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                achievement.description,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? AppTheme.correct.withOpacity(0.15)
                      : AppTheme.textMuted.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  achievement.isUnlocked ? '✅ Unlocked!' : '🔒 Locked',
                  style: TextStyle(
                    color: achievement.isUnlocked
                        ? AppTheme.correct
                        : AppTheme.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TVButton(
                label: 'Close',
                color: AppTheme.primary,
                autofocus: true,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
