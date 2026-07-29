import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:quiz_app/services/api_client.dart';
import 'package:quiz_app/models/question.dart';

@GenerateMocks([Dio])
import 'api_client_test.mocks.dart';

void main() {
  late MockDio mockDio;
  late ApiClient apiClient;

  setUp(() {
    mockDio = MockDio();
    // ApiClient constructor adds interceptors, so we need to stub the interceptors getter
    when(mockDio.interceptors).thenReturn(Interceptors());
    apiClient = ApiClient(dio: mockDio);
  });

  group('ApiClient Tests', () {
    test('fetchQuestions returns a List<Question> on 200 OK', () async {
      // Arrange
      final fakeJson = {
        'results': [
          {
            'type': 'multiple',
            'difficulty': 'medium',
            'category': 'General Knowledge',
            'question': 'What is the capital of France?',
            'correct_answer': 'Paris',
            'incorrect_answers': ['London', 'Berlin', 'Madrid'],
          }
        ]
      };
      
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: fakeJson,
          statusCode: 200,
        ),
      );

      // Act
      final result = await apiClient.fetchQuestions();

      // Assert
      expect(result, isA<List<Question>>());
      expect(result.length, 1);
      expect(result.first.text, 'What is the capital of France?');
    });

    test('fetchQuestions throws Exception on non-200 response', () async {
      // Arrange
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
          statusMessage: 'Not Found',
        ),
      );

      // Act & Assert
      expect(
        () async => await apiClient.fetchQuestions(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
