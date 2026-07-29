import 'package:quiz_app/models/question.dart';
import 'package:quiz_app/services/api_client.dart';

class QuizRepository {
  final ApiClient _apiClient;

  QuizRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<Question>> fetchQuestions({
    int amount = 10,
    String difficulty = 'medium',
  }) async {
    return await _apiClient.fetchQuestions(amount: amount, difficulty: difficulty);
  }
}
