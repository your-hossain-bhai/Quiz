import 'package:firebase_ai/firebase_ai.dart';
import 'package:quiz_app/services/ai_service.dart';
import 'package:quiz_app/models/question.dart';

class AiRepository {
  final AiService aiService;

  AiRepository({required this.aiService});

  Stream<GenerateContentResponse> sendMessageStream(String text) {
    return aiService.sendMessageStream(text);
  }

  Future<Map<int, String>?> generateExplanationsBatch(
    List<Map<String, dynamic>> wrongAnswers,
  ) {
    return aiService.generateExplanationsBatch(wrongAnswers);
  }

  Future<List<Question>?> generateQuiz(String prompt) {
    return aiService.generateQuiz(prompt);
  }
}
