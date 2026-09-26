import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/category_provider.dart';
import 'providers/quiz_provider.dart';
import 'services/opentdb_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final openTdb = OpenTdbService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(service: openTdb),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizProvider(service: openTdb)..loadSavedConfig(),
        ),
      ],
      child: const QuizzicalApp(),
    ),
  );
}
