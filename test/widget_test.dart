import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/app.dart';
import 'package:recipe_app/providers/category_provider.dart';
import 'package:recipe_app/providers/quiz_provider.dart';

void main() {
  testWidgets('Welcome screen shows Quizzical and Start Quiz', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => QuizProvider()),
        ],
        child: const QuizzicalApp(),
      ),
    );

    expect(find.text('Quizzical'), findsOneWidget);
    expect(find.text('START QUIZ'), findsOneWidget);
  });
}
