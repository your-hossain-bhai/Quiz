import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// TODO: Update this import to match the actual location of your ResultScreen
// import 'package:quiz_app/widgets/result_screen.dart';

void main() {
  testWidgets('ResultScreen correctly renders the score and the Share button', (WidgetTester tester) async {
    // Pass a mock score into the widget.
    const int mockScore = 80;

    // Use tester.pumpWidget() to load the ResultScreen wrapped in a MaterialApp.
    // (Assuming ResultScreen is available in the current scope or imported above)
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          // Replace with actual widget import when ready
          body: ResultScreen(finalScore: mockScore),
        ),
      ),
    );

    // Check that tester.pump() is used if any animations or state changes are expected.
    // Calling pumpAndSettle() will pump frames until there are no more scheduled frames.
    await tester.pumpAndSettle();

    // Use find.text() to assert that the string "Your Score: 80" appears exactly once.
    expect(find.text('Your Score: 80'), findsOneWidget);

    // Use find.byType(ElevatedButton) or find.byIcon(Icons.share) to verify the Share button exists.
    // Checking for both possibilities to ensure robustness depending on implementation.
    final shareButtonByType = find.byType(ElevatedButton);
    final shareButtonByIcon = find.byIcon(Icons.share);

    // We expect at least one of these to exist based on the constraints.
    expect(
      shareButtonByType.evaluate().isNotEmpty || shareButtonByIcon.evaluate().isNotEmpty,
      isTrue,
      reason: 'Could not find Share button by ElevatedButton type or Icons.share icon.',
    );
  });
}

// Dummy implementation of ResultScreen to allow the test file to compile without errors.
// Remove this class once you import the actual ResultScreen from your app!
class ResultScreen extends StatelessWidget {
  final int finalScore;

  const ResultScreen({super.key, required this.finalScore});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Your Score: $finalScore'),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.share),
          label: const Text('Share'),
        ),
      ],
    );
  }
}
