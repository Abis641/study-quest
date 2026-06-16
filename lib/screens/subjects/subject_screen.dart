// lib/screens/subjects/subject_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_theme.dart';
import '../../config/app_router.dart';
import '../../models/lesson_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/progress_service.dart';
import '../../services/user_service.dart';
import '../../widgets/tv_focusable_card.dart';

class SubjectScreen extends ConsumerWidget {
  final String subjectId;

  const SubjectScreen({super.key, required this.subjectId});

  Gradient _getGradient() {
    switch (subjectId) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final subject = SubjectData.findById(subjectId);
    final lessonsAsync = ref.watch(lessonsProvider(subjectId));
    final progressAsync = ref.watch(progressProvider(subjectId));

    if (subject == null) {
      return Scaffold(
        body: Center(child: Text('Subject not found: $subjectId')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Column(
          children: [
            // Header
            _SubjectHeader(subject: subject, gradient: _getGradient()),

            // Content
            Expanded(
              child: lessonsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (lessons) {
                  final progress = progressAsync.value;
                  final completedLessons =
                      progress?.completedLessons ?? [];
                  final completedQuizzes =
                      progress?.completedQuizzes ?? [];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lessons',
                          style:
                              Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: lessons.asMap().entries.map((entry) {
                            final i = entry.key;
                            final lesson = entry.value;
                            final isDone =
                                completedLessons.contains(lesson.id);
                            final quizDone = lesson.quizId != null &&
                                completedQuizzes
                                    .contains(lesson.quizId);
                            return _LessonCard(
                              lesson: lesson,
                              isDone: isDone,
                              quizDone: quizDone,
                              gradient: _getGradient(),
                              onTapLesson: () => _openLesson(
                                  context, lesson, ref),
                              onTapQuiz: lesson.quizId != null
                                  ? () => context.push(
                                      '${AppRoutes.quiz}/${lesson.quizId}')
                                  : null,
                            )
                                .animate()
                                .fadeIn(delay: (i * 80).ms)
                                .slideY(begin: 0.2);
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

  void _openLesson(
      BuildContext context, LessonModel lesson, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LessonDetailSheet(
        lesson: lesson,
        subjectId: subjectId,
        ref: ref,
      ),
    );
  }
}

class _SubjectHeader extends StatelessWidget {
  final SubjectModel subject;
  final Gradient gradient;

  const _SubjectHeader({required this.subject, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(gradient: gradient),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Row(
        children: [
          TVFocusableCard(
            onTap: () => Navigator.of(context).pop(),
            backgroundColor: Colors.white.withOpacity(0.15),
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 24),
          Text(subject.emoji, style: const TextStyle(fontSize: 60)),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subject.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final LessonModel lesson;
  final bool isDone;
  final bool quizDone;
  final Gradient gradient;
  final VoidCallback onTapLesson;
  final VoidCallback? onTapQuiz;

  const _LessonCard({
    required this.lesson,
    required this.isDone,
    required this.quizDone,
    required this.gradient,
    required this.onTapLesson,
    this.onTapQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return TVFocusableCard(
      onTap: onTapLesson,
      width: 340,
      backgroundColor: AppTheme.cardBase,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(lesson.emoji, style: const TextStyle(fontSize: 36)),
              const Spacer(),
              if (isDone)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.correct.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          color: AppTheme.correct, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Done',
                        style: TextStyle(
                          color: AppTheme.correct,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            lesson.title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lesson.description,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TVButton(
                  label: isDone ? 'Review' : 'Learn',
                  icon: Icons.menu_book_rounded,
                  color: AppTheme.primary,
                  onPressed: onTapLesson,
                ),
              ),
              if (onTapQuiz != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: TVButton(
                    label: quizDone ? 'Retry' : 'Quiz',
                    icon: Icons.quiz_rounded,
                    color: quizDone
                        ? AppTheme.textMuted
                        : AppTheme.secondary,
                    onPressed: onTapQuiz,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _LessonDetailSheet extends StatefulWidget {
  final LessonModel lesson;
  final String subjectId;
  final WidgetRef ref;

  const _LessonDetailSheet({
    required this.lesson,
    required this.subjectId,
    required this.ref,
  });

  @override
  State<_LessonDetailSheet> createState() => _LessonDetailSheetState();
}

class _LessonDetailSheetState extends State<_LessonDetailSheet> {
  bool _completed = false;

  Future<void> _markComplete() async {
    final uid =
        widget.ref.read(currentUserIdProvider);
    if (uid == null) return;

    final progressService =
        widget.ref.read(progressServiceProvider);
    await progressService.markLessonComplete(
        uid, widget.subjectId, widget.lesson.id);

    final userService = widget.ref.read(userServiceProvider);
    await userService.addXp(uid, 20);
    await userService.addCoins(uid, 10);

    setState(() => _completed = true);
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Text(lesson.emoji,
                    style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        lesson.description,
                        style: const TextStyle(
                            color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(color: AppTheme.surfaceVariant),

          // Content
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: lesson.content.length,
              itemBuilder: (_, i) =>
                  _ContentBlock(content: lesson.content[i]),
            ),
          ),

          // Complete button
          Padding(
            padding: const EdgeInsets.all(24),
            child: _completed
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.correct.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle,
                            color: AppTheme.correct, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Lesson Complete! +20 XP, +10 Coins',
                          style: TextStyle(
                            color: AppTheme.correct,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                : TVButton(
                    label: 'Mark as Complete  ✓',
                    color: AppTheme.correct,
                    autofocus: true,
                    onPressed: _markComplete,
                    width: double.infinity,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ContentBlock extends StatelessWidget {
  final LessonContent content;

  const _ContentBlock({required this.content});

  @override
  Widget build(BuildContext context) {
    if (content.type == 'fact') {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.3),
          ),
        ),
        child: Text(
          content.content,
          style: const TextStyle(
            color: AppTheme.primaryLight,
            fontSize: 15,
            height: 1.6,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        content.content,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 16,
          height: 1.7,
        ),
      ),
    );
  }
}
