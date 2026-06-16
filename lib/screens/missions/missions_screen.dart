// lib/screens/missions/missions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_theme.dart';
import '../../models/lesson_model.dart';
import '../../providers/user_provider.dart';
import '../../widgets/tv_focusable_card.dart';

class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionsAsync = ref.watch(dailyMissionsProvider);
    final user = ref.watch(userProvider);

    final now = DateTime.now();
    final dateStr =
        '${_weekday(now.weekday)}, ${now.day} ${_month(now.month)}';

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
                  colors: [Color(0xFFFFD166), Color(0xFFFF9F1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  TVFocusableCard(
                    onTap: () => Navigator.of(context).pop(),
                    backgroundColor: Colors.white.withOpacity(0.2),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 20),
                  const Text('🎯', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Missions',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800),
                      ),
                      Text(
                        dateStr,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 15),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (user != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Text('🔥',
                              style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(
                            '${user.currentStreak} day streak',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: missionsAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.secondary)),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (missions) {
                  final completed =
                      missions.where((m) => m.isCompleted).length;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBase,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$completed / ${missions.length} Completed',
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: missions.isNotEmpty
                                            ? completed / missions.length
                                            : 0,
                                        backgroundColor: AppTheme.textMuted
                                            .withOpacity(0.3),
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                                AppTheme.secondary),
                                        minHeight: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                children: [
                                  Text(
                                    completed == missions.length &&
                                            missions.isNotEmpty
                                        ? '🎉'
                                        : '⏳',
                                    style:
                                        const TextStyle(fontSize: 40),
                                  ),
                                  Text(
                                    completed == missions.length &&
                                            missions.isNotEmpty
                                        ? 'All Done!'
                                        : 'In Progress',
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          'Today\'s Missions',
                          style:
                              Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),

                        ...missions.asMap().entries.map((entry) {
                          final i = entry.key;
                          final mission = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _MissionCard(mission: mission)
                                .animate()
                                .fadeIn(delay: (i * 100).ms)
                                .slideX(begin: -0.1),
                          );
                        }),

                        const SizedBox(height: 32),

                        // Tips section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    AppTheme.primary.withOpacity(0.3)),
                          ),
                          child: const Row(
                            children: [
                              Text('💡',
                                  style: TextStyle(fontSize: 28)),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Complete all missions to earn bonus XP!',
                                      style: TextStyle(
                                        color: AppTheme.primaryLight,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'New missions arrive every day at midnight.',
                                      style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

  String _weekday(int d) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1];

  String _month(int m) => [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];
}

class _MissionCard extends StatelessWidget {
  final MissionModel mission;

  const _MissionCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    final isComplete = mission.isCompleted;

    return TVFocusableCard(
      onTap: () {},
      backgroundColor: AppTheme.cardBase,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isComplete
                  ? AppTheme.correct.withOpacity(0.15)
                  : AppTheme.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                _missionEmoji(mission.type),
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  style: TextStyle(
                    color: isComplete
                        ? AppTheme.textMuted
                        : AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    decoration: isComplete
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                Text(
                  mission.description,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: mission.progress.clamp(0.0, 1.0),
                          backgroundColor:
                              AppTheme.textMuted.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation(
                            isComplete
                                ? AppTheme.correct
                                : AppTheme.secondary,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${mission.currentCount}/${mission.targetCount}',
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Rewards
          Column(
            children: [
              _MissionReward(
                  emoji: '✨', value: '+${mission.xpReward}'),
              const SizedBox(height: 6),
              _MissionReward(
                  emoji: '🪙', value: '+${mission.coinReward}'),
            ],
          ),

          const SizedBox(width: 12),

          // Status
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isComplete
                  ? AppTheme.correct
                  : AppTheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isComplete ? Icons.check : Icons.radio_button_unchecked,
              color: isComplete ? Colors.white : AppTheme.textMuted,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  String _missionEmoji(MissionType type) {
    switch (type) {
      case MissionType.answerQuestions:
        return '❓';
      case MissionType.completeQuiz:
        return '📝';
      case MissionType.learnWords:
        return '📖';
      case MissionType.studySubject:
        return '🎓';
    }
  }
}

class _MissionReward extends StatelessWidget {
  final String emoji;
  final String value;

  const _MissionReward({required this.emoji, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$emoji $value',
        style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
