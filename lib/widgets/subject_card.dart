// lib/widgets/subject_card.dart
import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../config/app_theme.dart';
import 'tv_focusable_card.dart';

class SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final VoidCallback onTap;
  final FocusNode? focusNode;
  final bool autofocus;
  final int? completedLessons;
  final int? totalLessons;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.completedLessons,
    this.totalLessons,
  });

  Gradient get _gradient {
    switch (subject.id) {
      case 'math':
        return AppTheme.mathGradient;
      case 'science':
        return AppTheme.scienceGradient;
      case 'english':
        return AppTheme.englishGradient;
      case 'geography':
        return AppTheme.geographyGradient;
      default:
        return AppTheme.primaryGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TVFocusableCard(
      onTap: onTap,
      focusNode: focusNode,
      autofocus: autofocus,
      width: TVSizes.cardWidth,
      height: TVSizes.cardHeight,
      gradient: _gradient,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                subject.emoji,
                style: const TextStyle(fontSize: 40),
              ),
              const Spacer(),
              if (completedLessons != null && totalLessons != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$completedLessons/$totalLessons',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            subject.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subject.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (completedLessons != null && totalLessons != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: totalLessons! > 0
                    ? completedLessons! / totalLessons!
                    : 0,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Quick Action Card ─────────────────────────────────────────────────────

class ActionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final FocusNode? focusNode;
  final bool autofocus;

  const ActionCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TVFocusableCard(
      onTap: onTap,
      focusNode: focusNode,
      autofocus: autofocus,
      width: TVSizes.cardWidth,
      height: TVSizes.cardHeight,
      backgroundColor: AppTheme.cardBase,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 30)),
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
