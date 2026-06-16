// lib/screens/quiz/quiz_result_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_theme.dart';
import '../../config/app_router.dart';
import '../../widgets/tv_focusable_card.dart';

class QuizResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final int xpEarned;
  final int coinsEarned;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.xpEarned,
    required this.coinsEarned,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    if (widget.score / widget.total >= 0.7) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  double get _percentage =>
      widget.total > 0 ? widget.score / widget.total : 0;

  int get _stars {
    if (_percentage == 1.0) return 3;
    if (_percentage >= 0.7) return 2;
    if (_percentage >= 0.5) return 1;
    return 0;
  }

  String get _grade {
    if (_percentage == 1.0) return 'PERFECT!';
    if (_percentage >= 0.9) return 'EXCELLENT!';
    if (_percentage >= 0.7) return 'GREAT JOB!';
    if (_percentage >= 0.5) return 'GOOD TRY!';
    return 'KEEP GOING!';
  }

  Color get _gradeColor {
    if (_percentage >= 0.7) return AppTheme.correct;
    if (_percentage >= 0.5) return AppTheme.secondary;
    return AppTheme.incorrect;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppTheme.primary,
                AppTheme.secondary,
                AppTheme.correct,
                AppTheme.englishColor,
                AppTheme.scienceColor,
              ],
              numberOfParticles: 30,
            ),
          ),

          Container(
            decoration: const BoxDecoration(
                gradient: AppTheme.backgroundGradient),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.xxl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Grade label
                      Text(
                        _grade,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: _gradeColor,
                          letterSpacing: 2,
                        ),
                      )
                          .animate()
                          .scale(
                            duration: 500.ms,
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(),

                      const SizedBox(height: 8),

                      // Stars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '⭐',
                              style: TextStyle(
                                fontSize: 40,
                                color: i < _stars
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.2),
                              ),
                            ),
                          ).animate(delay: (200 + i * 100).ms).scale(
                                duration: 400.ms,
                                curve: Curves.elasticOut,
                              );
                        }),
                      ),

                      const SizedBox(height: 40),

                      // Score circle
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _gradeColor, width: 6),
                          color: _gradeColor.withOpacity(0.1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${widget.score}/${widget.total}',
                              style: TextStyle(
                                color: _gradeColor,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${(_percentage * 100).round()}%',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .scale(delay: 300.ms, duration: 500.ms)
                          .fadeIn(),

                      const SizedBox(height: 40),

                      // Rewards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _RewardChip(
                              emoji: '✨',
                              label: '+${widget.xpEarned} XP',
                              color: AppTheme.tertiary),
                          const SizedBox(width: 16),
                          _RewardChip(
                              emoji: '🪙',
                              label: '+${widget.coinsEarned} Coins',
                              color: AppTheme.secondary),
                          if (_stars > 0) ...[
                            const SizedBox(width: 16),
                            _RewardChip(
                                emoji: '⭐',
                                label: '+$_stars Stars',
                                color: const Color(0xFFFFD166)),
                          ],
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 500.ms)
                          .slideY(begin: 0.3),

                      const SizedBox(height: 48),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TVButton(
                            label: 'Home',
                            icon: Icons.home_rounded,
                            color: AppTheme.surfaceVariant,
                            onPressed: () => context.go(AppRoutes.home),
                          ),
                          const SizedBox(width: 16),
                          TVButton(
                            label: 'Play Again',
                            icon: Icons.refresh_rounded,
                            color: AppTheme.primary,
                            autofocus: true,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ).animate().fadeIn(delay: 700.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _RewardChip(
      {required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
