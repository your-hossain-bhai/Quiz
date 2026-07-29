import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/app_route.dart';
import 'package:quiz_app/models/question.dart';
import 'package:quiz_app/providers/quiz_provider.dart';

class QuizLoadingPage extends StatefulWidget {
  const QuizLoadingPage({super.key});

  @override
  State<QuizLoadingPage> createState() => _QuizLoadingPageState();
}

class _QuizLoadingPageState extends State<QuizLoadingPage> {
  late Future<List<Question>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  void fetchQuestions() {
    setState(() {
      _questionsFuture = context.read<QuizProvider>().fetchQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading Quiz'),
        leading: Semantics(
          label: 'Go Back',
          child: IconButton(
            tooltip: 'Go Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.go(AppRoute.home);
            },
          ),
        ),
      ),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: 'category-${context.read<QuizProvider>().categoryName}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        context.read<QuizProvider>().categoryName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Loading quiz...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Failed to load quiz: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: fetchQuestions,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final questions = snapshot.data!;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.replace(AppRoute.quizQuestion, extra: questions);
            });
            return const SizedBox.shrink();
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
