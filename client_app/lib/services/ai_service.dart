import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:quiz_app/models/question.dart';

class AiService {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  AiService() {
    _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-1.5-flash');
    _chat = _model.startChat();
  }

  Stream<GenerateContentResponse> sendMessageStream(String text) {
    return _chat.sendMessageStream(Content.text(text));
  }

  Future<Map<int, String>?> generateExplanationsBatch(
    List<Map<String, dynamic>> wrongAnswers,
  ) async {
    if (wrongAnswers.isEmpty) return {};

    final prompt =
        '''
You are an AI assistant for a quiz app. I will provide a list of wrong answers submitted by a user.
For each item, explain briefly (in 1-2 sentences) why the user's answer is wrong and why the correct one is correct.
Return the result strictly as a JSON object where the keys are the "questionIndex" and the values are the "explanation".

Here is the data:
${wrongAnswers.map((w) => "questionIndex: ${w['index']}, Question: ${w['question']}, User Answer: ${w['selectedAnswer']}, Correct Answer: ${w['correctAnswer']}").join('\n')}
''';

    final jsonModel = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );

    final response = await jsonModel.generateContent([Content.text(prompt)]);
    final text = response.text;
    if (text != null) {
      try {
        final decoded = jsonDecode(text) as Map<String, dynamic>;
        return decoded.map(
          (key, value) => MapEntry(int.parse(key), value.toString()),
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<List<Question>?> generateQuiz(String prompt) async {
    final instructions = '''
You are a quiz generator. Generate a 10-question multiple-choice quiz about: $prompt.
Return the result strictly as a JSON array of objects, where each object represents a question.
Each object must have the following keys:
- "question": The question text (string)
- "correct_answer": The correct answer (string)
- "incorrect_answers": An array of exactly 3 incorrect answers (array of strings)
- "difficulty": "easy", "medium", or "hard" (string)

Example format:
[
  {
    "question": "What is 2 + 2?",
    "correct_answer": "4",
    "incorrect_answers": ["3", "5", "6"],
    "difficulty": "easy"
  }
]
''';

    final jsonModel = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );

    final response = await jsonModel.generateContent([Content.text(instructions)]);
    final text = response.text;
    if (text != null) {
      try {
        final decoded = jsonDecode(text) as List<dynamic>;
        return decoded.map((q) => Question.fromJson(q as Map<String, dynamic>)).toList();
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
