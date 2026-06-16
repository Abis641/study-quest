// lib/screens/quiz/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_theme.dart';
import '../../config/app_router.dart';
import '../../models/quiz_model.dart';
import '../../providers/user_provider.dart';
import '../../widgets/tv_focusable_card.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String quizId;

  const QuizScreen({super.key, required this.quizId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  String? _selectedAnswer;
  bool _answered = false;
  bool _isCorrect = false;
  final _fillController = TextEditingController();
  final List<FocusNode> _optionFocuses = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizAsync = ref.read(quizProvider(widget.quizId));
      quizAsync.whenData((quiz) {
        if (quiz != null) {
          ref.read(quizNotifierProvider.notifier).loadQuiz(quiz);
        }
      });
    });
  }

  @override
  void dispose() {
    _fillController.dispose();
    for (final f in _optionFocuses) {
      f.dispose();
    }
    super.dispose();
  }

  void _selectAnswer(String answer) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null && _fillController.text.trim().isEmpty) return;
    if (_answered) return;

    final quizState = ref.read(quizNotifierProvider);
    final question = quizState.currentQuestion;
    if (question == null) return;

    final answer = question.type == QuestionType.fillBlank
        ? _fillController.text.trim()
        : _selectedAnswer!;

    final correct =
        answer.toLowerCase() == question.correctAnswer.toLowerCase();

    setState(() {
      _answered = true;
      _isCorrect = correct;
      _selectedAnswer = answer;
    });

    ref.read(quizNotifierProvider.notifier).answerQuestion(answer);
  }

  void _next() {
    final quizState = ref.read(quizNotifierProvider);

    setState(() {
      _answered = false;
      _selectedAnswer = null;
      _isCorrect = false;
      _fillController.clear();
    });

    if (quizState.isLastQuestion) {
      ref.read(quizNotifierProvider.notifier).nextQuestion();

      final state = ref.read(quizNotifierProvider);
      context.go(
        AppRoutes.quizResult,
        extra: {
          'score': state.score,
          'total': state.quiz?.questions.length ?? 0,
          'xpEarned': state.xpEarned,
          'coinsEarned': state.coinsEarned,
        },
      );
    } else {
      ref.read(quizNotifierProvider.notifier).nextQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(quizProvider(widget.quizId));
    final quizState = ref.watch(quizNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: quizAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(child: Text('Error loading quiz: $e')),
        data: (quiz) {
          if (quiz == null) {
            return const Center(child: Text('Quiz not found'));
          }

          final question = quizState.currentQuestion;
          if (question == null || quizState.isFinished) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }

          // Rebuild focus nodes only when option count changes (safe in build)
          if (_optionFocuses.length != question.options.length + 1) {
            _optionFocuses.forEach((f) => f.dispose());
            _optionFocuses.clear();
            for (var i = 0; i < question.options.length + 1; i++) {
              _optionFocuses.add(FocusNode());
            }
          }

          return Container(
            decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
            child: Column(
              children: [
                _buildTopBar(context, quiz, quizState),
                Expanded(
                  child: Row(
                    children: [
                      // Question panel
                      Expanded(
                        flex: 5,
                        child: _buildQuestionPanel(question),
                      ),
                      // Answer panel
                      Expanded(
                        flex: 5,
                        child: _buildAnswerPanel(question),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(
      BuildContext context, QuizModel quiz, QuizState quizState) {
    final progress = quizState.quiz != null
        ? (quizState.currentIndex + 1) / quizState.quiz!.questions.length
        : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
      child: Row(
        children: [
          TVFocusableCard(
            onTap: () => Navigator.of(context).pop(),
            backgroundColor: AppTheme.surfaceVariant,
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.close, color: AppTheme.textSecondary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Q${quizState.currentIndex + 1} / ${quiz.questions.length}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.textMuted.withOpacity(0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  '${quizState.score}',
                  style: const TextStyle(
                    color: AppTheme.secondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPanel(QuizQuestion question) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _questionTypeLabel(question.type),
              style: const TextStyle(
                color: AppTheme.primaryLight,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            question.question,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),

          if (_answered) ...[
            const SizedBox(height: 32),
            _FeedbackCard(
              isCorrect: _isCorrect,
              explanation: question.explanation,
              xpReward: question.xpReward,
              coinReward: question.coinReward,
            ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
          ],

          if (_answered) ...[
            const SizedBox(height: 24),
            TVButton(
              label: 'Next →',
              color: AppTheme.primary,
              autofocus: true,
              onPressed: _next,
              width: double.infinity,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerPanel(QuizQuestion question) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 40, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (question.type == QuestionType.fillBlank)
            _FillBlankInput(
              controller: _fillController,
              onSubmit: _submitAnswer,
              answered: _answered,
            )
          else
            ..._buildOptions(question),

          if (!_answered) ...[
            const SizedBox(height: 24),
            TVButton(
              label: 'Submit Answer',
              icon: Icons.send_rounded,
              color: _selectedAnswer != null
                  ? AppTheme.primary
                  : AppTheme.textMuted,
              onPressed: _selectedAnswer != null ? _submitAnswer : null,
              width: double.infinity,
              focusNode: _optionFocuses.isNotEmpty
                  ? _optionFocuses.last
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildOptions(QuizQuestion question) {
    return question.options.asMap().entries.map((entry) {
      final i = entry.key;
      final option = entry.value;

      Color? bgColor;
      if (_answered) {
        if (option == question.correctAnswer) {
          bgColor = AppTheme.correct.withOpacity(0.2);
        } else if (option == _selectedAnswer &&
            option != question.correctAnswer) {
          bgColor = AppTheme.incorrect.withOpacity(0.2);
        }
      } else if (_selectedAnswer == option) {
        bgColor = AppTheme.primary.withOpacity(0.2);
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TVFocusableCard(
          onTap: _answered ? null : () => _selectAnswer(option),
          focusNode:
              i < _optionFocuses.length ? _optionFocuses[i] : null,
          autofocus: i == 0 && !_answered,
          backgroundColor: bgColor ?? AppTheme.cardBase,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _answered && option == question.correctAnswer
                      ? AppTheme.correct
                      : _answered &&
                              option == _selectedAnswer &&
                              option != question.correctAnswer
                          ? AppTheme.incorrect
                          : _selectedAnswer == option
                              ? AppTheme.primary
                              : AppTheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _answered && option == question.correctAnswer
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : _answered &&
                              option == _selectedAnswer &&
                              option != question.correctAnswer
                          ? const Icon(Icons.close, color: Colors.white, size: 18)
                          : Text(
                              String.fromCharCode(65 + i), // A, B, C, D
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    color: _answered && option == question.correctAnswer
                        ? AppTheme.correct
                        : _answered &&
                                option == _selectedAnswer &&
                                option != question.correctAnswer
                            ? AppTheme.incorrect
                            : AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (i * 60).ms).slideX(begin: 0.1),
      );
    }).toList();
  }

  String _questionTypeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return '🎯 Multiple Choice';
      case QuestionType.trueFalse:
        return '✅ True or False';
      case QuestionType.fillBlank:
        return '✏️ Fill in the Blank';
    }
  }
}

class _FeedbackCard extends StatelessWidget {
  final bool isCorrect;
  final String explanation;
  final int xpReward;
  final int coinReward;

  const _FeedbackCard({
    required this.isCorrect,
    required this.explanation,
    required this.xpReward,
    required this.coinReward,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppTheme.correct : AppTheme.incorrect;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isCorrect ? '🎉 Correct!' : '❌ Not quite!',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (isCorrect) ...[
                _RewardBadge(emoji: '✨', value: '+$xpReward XP'),
                const SizedBox(width: 8),
                _RewardBadge(emoji: '🪙', value: '+$coinReward'),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardBadge extends StatelessWidget {
  final String emoji;
  final String value;

  const _RewardBadge({required this.emoji, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$emoji $value',
        style: const TextStyle(
          color: AppTheme.secondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FillBlankInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final bool answered;

  const _FillBlankInput({
    required this.controller,
    required this.onSubmit,
    required this.answered,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.4), width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextField(
        controller: controller,
        autofocus: !answered,
        enabled: !answered,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        decoration: const InputDecoration(
          hintText: 'Type your answer...',
          hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 18),
          border: InputBorder.none,
        ),
        onSubmitted: (_) => onSubmit(),
      ),
    );
  }
}
