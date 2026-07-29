import 'question.dart';
import 'quiz_category.dart';

class Quiz {
  final String name;
  final QuizCategory category;
  final List<Question> questions;

  Quiz({required this.name, required this.category, required this.questions});
}
