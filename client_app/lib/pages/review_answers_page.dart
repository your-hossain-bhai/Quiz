import 'package:flutter/material.dart';
import 'package:quiz_app/models/quiz_result.dart';

class ReviewAnswersPage extends StatelessWidget {
  final QuizResult result;

  const ReviewAnswersPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Answers'),
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.08),
              colorScheme.surface,
            ],
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: result.questions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final question = result.questions[index];
            final selected = result.selectedAnswers[index];
            final correctIndex = question.correctOptionIndex;
            final isSkipped = selected == null;
            final isCorrect = !isSkipped && selected == correctIndex;
            final selectedText = isSkipped
                ? 'Skipped'
                : question.options[selected];
            final correctText = question.options[correctIndex];
            final cardColor = isCorrect ? Colors.green : Colors.red;

            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: cardColor.withValues(alpha: 0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: cardColor.withValues(alpha: 0.12),
                          child: Icon(
                            isCorrect ? Icons.check : Icons.close,
                            size: 16,
                            color: cardColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Question ${index + 1}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question.text,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _AnswerTile(
                      label: 'Your answer',
                      value: selectedText,
                      color: isCorrect ? Colors.green : Colors.red,
                      isHighlighted: !isSkipped,
                    ),
                    const SizedBox(height: 10),
                    _AnswerTile(
                      label: 'Correct answer',
                      value: correctText,
                      color: Colors.green,
                      isHighlighted: true,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isHighlighted;

  const _AnswerTile({
    required this.label,
    required this.value,
    required this.color,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isHighlighted ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
