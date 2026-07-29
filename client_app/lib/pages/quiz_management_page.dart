import 'package:flutter/material.dart';
import 'package:quiz_app/models/question.dart';

class QuizManagementPage extends StatefulWidget {
  const QuizManagementPage({super.key});

  @override
  State<QuizManagementPage> createState() => _QuizManagementPageState();
}

class _QuizManagementPageState extends State<QuizManagementPage> {
  final List<Question> questions = [];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _questionController = TextEditingController();

  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  int _correctOptionIndex = -1;

  @override
  Widget build(BuildContext context) {
    debugPrint('Building QuizManagementPage with ${questions.length} questions');

    return Scaffold(
      appBar: AppBar(title: Text('Quiz Management'), actions: [
          
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    spacing: 12,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Quiz Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a quiz title';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: 'Quiz Category',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a quiz category';
                          }
                          return null;
                        },
                      ),
    
                      Divider(height: 24),
                      Text(
                        'Add Questions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
    
                      TextFormField(
                        controller: _questionController,
                        decoration: InputDecoration(
                          labelText: 'New Question',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a question';
                          }
                          return null;
                        },
                      ),
    
                      SizedBox(height: 12),
    
                      ...List.generate(4, (index) {
                        return Row(
                          children: [
                            Radio<int>(
                              value: index,
                              // ignore: deprecated_member_use
                              groupValue: _correctOptionIndex,
                              // ignore: deprecated_member_use
                              onChanged: (value) {
                                setState(() {
                                  _correctOptionIndex = value!;
                                });
                              },
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _optionControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Option ${index + 1}',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter option ${index + 1}';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ElevatedButton(onPressed: _addQuestion, child: Text('Add')),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return ListTile(
                  title: Text(question.text),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(question.options.length, (
                      optionIndex,
                    ) {
                      final optionText = question.options[optionIndex];
                      final isCorrect =
                          optionIndex == question.correctOptionIndex;
                      return Text(
                        '${isCorrect ? "✓" : "•"} $optionText',
                        style: TextStyle(
                          color: isCorrect ? Colors.green : Colors.black,
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    if (_formKey.currentState!.validate()) {
      final questionText = _questionController.text.trim();
      final options = List.generate(
        4,
        (index) => _optionControllers[index].text.trim(),
      );

      if (_correctOptionIndex == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select the correct option')),
        );
        return;
      }

      final newQuestion = Question(
        text: questionText,
        options: options,
        correctOptionIndex: _correctOptionIndex,
      );

      setState(() {
        questions.add(newQuestion);
        _questionController.clear();
        for (var controller in _optionControllers) {
          controller.clear();
        }
        _correctOptionIndex = -1; // Reset correct option selection
      });
    }
  }
}
