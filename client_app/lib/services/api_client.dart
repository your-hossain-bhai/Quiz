import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/question.dart';

class ApiClient {
  static const String _baseUrl = 'https://opentdb.com/api.php';
  late Dio _dio;

  ApiClient({Dio? dio}) {
    _dio =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('Requesting: ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('Response: ${response.statusCode} ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('Error: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  Future<List<Question>> fetchQuestions({
    int amount = 10,
    String difficulty = 'medium',
  }) async {
    try {
      final response = await _dio.get(
        '',
        queryParameters: {'amount': amount, 'difficulty': difficulty},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<Question> questions = (data['results'] as List)
            .map((json) => Question.fromJson(json))
            .toList();
        debugPrint('Fetched ${questions.length} questions from API');

        final prefs = await SharedPreferences.getInstance();
        final jsonString = jsonEncode(
          questions.map((q) => q.toJson()).toList(),
        );
        await prefs.setString('cached_questions', jsonString);

        return questions;
      } else {
        throw Exception('Failed to fetch questions');
      }
    } catch (e) {
      debugPrint('Network error, attempting to load from cache: $e');
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString('cached_questions');
      if (cachedString != null && cachedString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cachedString);
        final cachedQuestions = decoded
            .map((json) => Question.fromJson(json))
            .toList();
        debugPrint('Loaded ${cachedQuestions.length} questions from cache');
        return cachedQuestions;
      }
      throw Exception('Failed to fetch questions and cache is empty');
    }
  }
}
