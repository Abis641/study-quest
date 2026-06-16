// lib/widgets/stats_bar.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../config/app_theme.dart';

class StatsBar extends StatelessWidget {
  final UserModel user;

  const StatsBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xl, vertical: Spacing.md),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            emoji: '⚡',
            label: 'Level',
            value: '${user.level}',
            color: AppTheme.primary,
          ),
          _Divider(),
          _XpItem(user: user),
          _Divider(),
          _StatItem(
            emoji: '🪙',
            label: 'Coins',
            value: '${user.coins}',
            color: AppTheme.secondary,
          ),
          _Divider(),
          _StatItem(
            emoji: '⭐',
            label: 'Stars',
            value: '${user.stars}',
            color: const Color(0xFFFFD166),
          ),
          _Divider(),
          _StatItem(
            emoji: '🔥',
            label: 'Streak',
            value: '${user.currentStreak}d',
            color: const Color(0xFFFF6B35),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.1),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _XpItem extends StatelessWidget {
  final UserModel user;

  const _XpItem({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('✨', style: TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          '${user.xp}/${user.xpForNextLevel}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.tertiary,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: user.levelProgress.clamp(0.0, 1.0),
              backgroundColor: AppTheme.textMuted.withOpacity(0.3),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.tertiary),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'XP',
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
