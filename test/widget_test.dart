import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/main.dart';

void main() {
  testWidgets('Quiz App smoke test - Home Screen loads subjects', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QuizApp());

    // Verify that the title 'My Quiz App' is displayed.
    expect(find.text('My Quiz App'), findsOneWidget);

    // Verify that the header greeting text is present.
    expect(find.text('Welcome back, Student 👋'), findsOneWidget);

    // Verify that Operating Systems subject card is displayed.
    expect(find.text('Operating Systems'), findsOneWidget);
  });
}
