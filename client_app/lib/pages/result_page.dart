// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/app_route.dart';

import 'package:quiz_app/models/quiz_result.dart';
import 'package:quiz_app/providers/ai_provider.dart';
import 'package:quiz_app/providers/quiz_provider.dart';
import 'package:quiz_app/providers/scoreboard_provider.dart';
import 'package:quiz_app/widgets/score_circle.dart';
import 'package:share_plus/share_plus.dart';

class ResultPage extends StatefulWidget {
  final QuizResult result;

  const ResultPage({super.key, required this.result});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScoreboardProvider>().saveQuizResult(widget.result);

      final wrongAnswers = <Map<String, dynamic>>[];
      for (var i = 0; i < widget.result.questions.length; i++) {
        final q = widget.result.questions[i];
        final selected = widget.result.selectedAnswers[i];
        final isSkipped = selected == null;
        final isCorrect = selected == q.correctOptionIndex;

        if (!isSkipped && !isCorrect) {
          wrongAnswers.add({
            'index': i,
            'question': q.text,
            'selectedAnswer': q.options[selected],
            'correctAnswer': q.options[q.correctOptionIndex],
          });
        }
      }

      if (wrongAnswers.isNotEmpty) {
        context.read<AiProvider>().fetchExplanationsBatch(wrongAnswers);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final colorScheme = Theme.of(context).colorScheme;
    final accuracy = result.accuracy;
    final wrongCount =
        result.totalQuestions - result.correctCount - _skippedCount;
    final accuracyPercent = (accuracy * 100).round();

    final (scoreColor, scoreLabel, scoreIcon) = accuracy >= 0.7
        ? (Colors.green, 'Excellent!', Icons.emoji_events)
        : accuracy >= 0.5
        ? (Colors.orange, 'Good Job!', Icons.thumb_up)
        : (Colors.red, 'Keep Practicing', Icons.refresh);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scoreColor.withValues(alpha: 0.15),
              scoreColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          children: [
            Center(
              child: Column(
                children: [
                  Transform.scale(
                    scale: 1.3,
                    child: Lottie.network(
                      'https://lottie.host/62f15475-3f56-4f84-8906-116af7888159/5e016EA2YU.json',
                      width: 110,
                      height: 110,
                      repeat: false,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(scoreIcon, color: scoreColor, size: 28),
                ],
              ),
            ),
            Center(
              child: Text(
                scoreLabel,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ScoreCircle(result: result, color: scoreColor),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatPill(
                      icon: Icons.check_circle,
                      label: 'Correct',
                      value: '${result.correctCount}',
                      color: Colors.green,
                    ),
                    _StatPill(
                      icon: Icons.cancel,
                      label: 'Wrong',
                      value: '$wrongCount',
                      color: Colors.red,
                    ),
                    _StatPill(
                      icon: Icons.percent,
                      label: 'Accuracy',
                      value: '$accuracyPercent%',
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _shareScore,
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share your score'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                context.push(AppRoute.reviewAnswers, extra: widget.result);
              },
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Review Answers'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Answer Review',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ...List.generate(result.questions.length, (i) {
              final q = result.questions[i];
              final selected = result.selectedAnswers[i];
              final isCorrect = selected == q.correctOptionIndex;
              final isSkipped = selected == null;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSkipped
                          ? Colors.grey.shade300
                          : isCorrect
                          ? Colors.green.shade200
                          : Colors.red.shade200,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isSkipped
                                  ? Icons.timer_off_outlined
                                  : isCorrect
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              color: isSkipped
                                  ? Colors.grey
                                  : isCorrect
                                  ? Colors.green
                                  : Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Q${i + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            if (isSkipped)
                              const _ReviewBadge(
                                label: 'Skipped',
                                color: Colors.grey,
                              )
                            else if (isCorrect)
                              const _ReviewBadge(
                                label: '+1 pt',
                                color: Colors.green,
                              )
                            else
                              const _ReviewBadge(
                                label: 'Wrong',
                                color: Colors.red,
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          q.text,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        if (!isSkipped && !isCorrect) ...[
                          _AnswerRow(
                            prefix: 'Your answer',
                            text: q.options[selected],
                            color: Colors.red,
                          ),
                          const SizedBox(height: 4),
                        ],
                        _AnswerRow(
                          prefix: 'Correct',
                          text: q.options[q.correctOptionIndex],
                          color: Colors.green,
                        ),
                        if (!isSkipped && !isCorrect) ...[
                          const SizedBox(height: 12),
                          _AiExplanationWidget(questionIndex: i),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
            // ── Action buttons ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<QuizProvider>().reset();
                        context.go(AppRoute.home);
                      },
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Home'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        context.read<QuizProvider>().startQuiz(null);
                        context.go(AppRoute.quizQuestion);
                      },
                      icon: const Icon(Icons.replay),
                      label: const Text('Play Again'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int get _skippedCount =>
      widget.result.selectedAnswers.where((a) => a == null).length;

  void _shareScore() {
    SharePlus.instance.share(
      ShareParams(
        text:
            'check out my quiz score: ${widget.result.score}/${widget.result.totalQuestions} in category "${widget.result.categoryName}"! Can you beat me?',
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _ReviewBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _ReviewBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final String prefix;
  final String text;
  final Color color;

  const _AnswerRow({
    required this.prefix,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$prefix: ',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 12, color: color)),
        ),
      ],
    );
  }
}

class _AiExplanationWidget extends StatelessWidget {
  final int questionIndex;

  const _AiExplanationWidget({required this.questionIndex});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiProvider>(
      builder: (context, aiProvider, child) {
        if (aiProvider.isGeneratingExplanations) {
          return const Row(
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text(
                'Generating AI explanation...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          );
        }

        final explanation = aiProvider.explanations[questionIndex];
        if (explanation == null) {
          return const SizedBox.shrink(); // Don't show error to keep UI clean if it fails or hasn't started
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.blue, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'AI Hint',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                explanation,
                style: const TextStyle(fontSize: 12, height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }
}
