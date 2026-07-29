import 'package:flutter/material.dart';

import '../models/quiz_category.dart';
import 'quiz_category_widget.dart';

class CategoryTypeWidget extends StatelessWidget {
  const CategoryTypeWidget({super.key, required this.categories});

  final List<QuizCategory> categories;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return QuizCategoryWidget(category: categories[index]);
      },
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
    );
  }
}
