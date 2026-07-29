import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:quiz_app/models/question.dart';
import 'package:quiz_app/models/quiz_result.dart';
import 'package:quiz_app/repository/quiz_repository.dart';

enum QuizStatus { idle, active, finished }

class QuizProvider extends ChangeNotifier {
  static const int totalSeconds = 15;

  final QuizRepository _repository;

  QuizProvider({QuizRepository? repository})
      : _repository = repository ?? QuizRepository();

  List<Question> _questions = [];
  int _currentIndex = 0;
  List<int?> _selectedAnswers = [];
  int _correctCount = 0;
  int _secondsLeft = totalSeconds;
  QuizStatus _status = QuizStatus.idle;
  Timer? _timer;
  String _categoryName = 'General Knowledge';
  DateTime _startTime = DateTime.now();

  List<Question> get questions => _questions;
  int get currentIndex => _currentIndex;
  List<int?> get selectedAnswers => _selectedAnswers;
  int get score => _correctCount;
  int get secondsLeft => _secondsLeft;
  QuizStatus get status => _status;
  String get categoryName => _categoryName;
  DateTime get startTime => _startTime;

  Question get currentQuestion => _questions[_currentIndex];

  bool get isLastQuestion => _currentIndex == _questions.length - 1;

  int? get currentAnswer => _selectedAnswers[_currentIndex];

  bool get hasAnswered => currentAnswer != null;

  void setCategoryName(String name) {
    _categoryName = name;
    notifyListeners();
  }

  QuizResult get result => QuizResult(
    totalQuestions: _questions.length,
    correctCount: _correctCount,
    score: _correctCount,
    selectedAnswers: List<int?>.from(_selectedAnswers),
    questions: List<Question>.from(_questions),
    categoryName: _categoryName,
    timestamp: _startTime,
  );

  Future<List<Question>> fetchQuestions({
    int amount = 10,
    String difficulty = 'medium',
  }) async {
    return await _repository.fetchQuestions(amount: amount, difficulty: difficulty);
  }

  // sample questions (hardcoded for now)
  static final List<Question> sampleQuestions = [
    Question(
      text: 'What is the capital of France?',
      options: ['Berlin', 'Madrid', 'Paris', 'Rome'],
      correctOptionIndex: 2,
      difficulty: 1,
    ),
    Question(
      text: 'Who wrote "To Kill a Mockingbird"?',
      options: [
        'Harper Lee',
        'Mark Twain',
        'Ernest Hemingway',
        'F. Scott Fitzgerald',
      ],
      correctOptionIndex: 0,
      difficulty: 2,
    ),
    Question(
      text: 'What is the largest planet in our solar system?',
      options: ['Earth', 'Jupiter', 'Mars', 'Saturn'],
      correctOptionIndex: 1,
      difficulty: 1,
    ),
    Question(
      text: 'Which element has the chemical symbol "O"?',
      options: ['Gold', 'Oxygen', 'Silver', 'Hydrogen'],
      correctOptionIndex: 1,
      difficulty: 1,
    ),
    Question(
      text: 'What year did the Berlin Wall fall?',
      options: ['1987', '1989', '1991', '1993'],
      correctOptionIndex: 1,
      difficulty: 3,
    ),
    Question(
      text: 'What is the capital of Germany?',
      options: ['Vienna', 'Zurich', 'Berlin', 'Hamburg'],
      correctOptionIndex: 2,
      difficulty: 1,
    ),
  ];

  void startQuiz(List<Question>? questions) {
    _questions = questions ?? sampleQuestions;
    _currentIndex = 0;
    _correctCount = 0;
    _selectedAnswers = List.filled(_questions.length, null);
    _secondsLeft = totalSeconds;
    _status = QuizStatus.active;
    _startTime = DateTime.now();
    _startTimer();
    notifyListeners();
  }

  void selectedAnswer(int answerIndex) {
    if (_status != QuizStatus.active || hasAnswered) return;

    _cancelTimer();
    _selectedAnswers[_currentIndex] = answerIndex;

    if (answerIndex == currentQuestion.correctOptionIndex) {
      _correctCount++;
    }
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), _advance);
  }

  void _advance() {
    if (isLastQuestion) {
      _status = QuizStatus.finished;
      _cancelTimer();
      notifyListeners();
    } else {
      _currentIndex++;
      _startTimer();
      notifyListeners();
    }
  }

  void _startTimer() {
    _secondsLeft = totalSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer timer) {
    if (_secondsLeft > 0) {
      _secondsLeft--;
      notifyListeners();
    } else {
      _cancelTimer();
    }
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Reset all state back to idle.
  void reset() {
    _cancelTimer();
    _questions = [];
    _currentIndex = 0;
    _selectedAnswers = [];
    _correctCount = 0;
    _secondsLeft = totalSeconds;
    _status = QuizStatus.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
