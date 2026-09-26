import 'package:flutter/material.dart';

import 'core/quiz_theme.dart';
import 'ui/screens/welcome_screen.dart';

class QuizzicalApp extends StatelessWidget {
  const QuizzicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quizzical',
      debugShowCheckedModeBanner: false,
      theme: quizTheme(),
      home: const WelcomeScreen(),
    );
  }
}
