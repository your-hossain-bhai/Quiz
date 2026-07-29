import 'package:flutter/material.dart';

class QuizCategory {
  final String name;
  final int questionCount;
  final IconData icon;
  final Color color;
  final String imageUrl;

  QuizCategory({
    required this.name,
    required this.questionCount,
    required this.icon,
    required this.color,
    required this.imageUrl,
  });
}