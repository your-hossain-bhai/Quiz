import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/models/question.dart';
import 'package:quiz_app/providers/quiz_provider.dart';
import 'package:quiz_app/providers/ai_provider.dart';
import 'package:firebase_ai/firebase_ai.dart';

import '../app_route.dart';

class QuizQuestionPage extends StatefulWidget {
  final List<Question> questions;

  const QuizQuestionPage({super.key, required this.questions});

  @override
  State<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage> {
  late QuizProvider _quizProvider;

  @override
  void initState() {
    super.initState();
    _quizProvider = context.read<QuizProvider>();
    _quizProvider.addListener(_onQuizStatusChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _quizProvider.startQuiz(widget.questions);
      debugPrint(
        '${widget.questions.length} questions loaded into QuizProvider',
      );
    });
  }

  void _onQuizStatusChanged() {
    if (_quizProvider.status == QuizStatus.finished) {
      if (mounted) {
        context.go(AppRoute.quizResult, extra: _quizProvider.result);
      }
    }
  }

  @override
  void dispose() {
    _quizProvider.removeListener(_onQuizStatusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<QuizProvider>(
      builder: (context, quiz, _) {
        if (quiz.questions.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Question ${quiz.currentIndex + 1} of ${quiz.questions.length}',
            ),
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Chip(
                  avatar: const Icon(Icons.star),
                  label: Text(
                    '${quiz.score} pts',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.07),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: LinearProgressIndicator(
                    value: (quiz.currentIndex + 1) / quiz.questions.length,
                    minHeight: 8,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Hero(
                                tag: 'category-${quiz.categoryName}',
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Text(
                                    quiz.categoryName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                              Chip(
                                avatar: const Icon(
                                  Icons.timer_outlined,
                                  size: 18,
                                ),
                                label: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    '${quiz.secondsLeft}s',
                                    key: ValueKey(quiz.secondsLeft),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Question ${quiz.currentIndex + 1}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    quiz.currentQuestion.text,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          height: 1.25,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(
                            quiz.currentQuestion.options.length,
                            (index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _AnswerOptionButton(
                                  label: quiz.currentQuestion.options[index],
                                  isSelected: quiz.currentAnswer == index,
                                  enabled: !quiz.hasAnswered,
                                  onTap: () => quiz.selectedAnswer(index),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Semantics(
            label: 'Request AI Hint',
            child: FloatingActionButton(
              tooltip: 'Request AI Hint',
              onPressed: () {
                HapticFeedback.lightImpact();
                _showHintDialog(context, quiz.currentQuestion);
              },
              child: const Icon(Icons.lightbulb_outline),
            ),
          ),
        );
      },
    );
  }

  void _showHintDialog(BuildContext context, Question currentQuestion) {
    showDialog(
      context: context,
      builder: (context) {
        return _HintDialog(currentQuestion: currentQuestion);
      },
    );
  }
}

class _AnswerOptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _AnswerOptionButton({
    required this.label,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isSelected
        ? colorScheme.primaryContainer
        : colorScheme.surface;
    final borderColor = isSelected
        ? colorScheme.primary
        : colorScheme.outlineVariant;

    return Material(
      color: backgroundColor,
      elevation: isSelected ? 2 : 0,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: isSelected ? 1.4 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                ),
                child: Icon(
                  isSelected ? Icons.check : Icons.circle_outlined,
                  size: 16,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? colorScheme.onPrimaryContainer : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HintDialog extends StatefulWidget {
  final Question currentQuestion;

  const _HintDialog({required this.currentQuestion});

  @override
  State<_HintDialog> createState() => _HintDialogState();
}

class _HintDialogState extends State<_HintDialog> {
  late Stream<GenerateContentResponse> _hintStream;
  String _hintText = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final aiRepo = context.read<AiProvider>().aiRepository;
    final prompt =
        "Give a very short, subtle hint for this quiz question without revealing the answer. Question: ${widget.currentQuestion.text}, Options: ${widget.currentQuestion.options.join(', ')}.";

    _hintStream = aiRepo.sendMessageStream(prompt);
    _hintStream.listen(
      (chunk) {
        if (mounted) {
          setState(() {
            _hintText += chunk.text ?? '';
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error generating hint.';
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hint'),
      content: _errorMessage != null
          ? Text(_errorMessage!)
          : _hintText.isEmpty
          ? const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(child: Text(_hintText)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
