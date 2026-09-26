import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/quiz_theme.dart';
import '../../providers/quiz_provider.dart';
import 'category_selection_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final percent = quiz.accuracyPercent.round();
    final good = percent >= 70;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 1),
              if (good)
                Icon(
                  Icons.celebration,
                  size: 96,
                  color: Colors.pink.shade300,
                )
              else
                Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Colors.orange.shade400,
                ),
              const SizedBox(height: 24),
              Text(
                good ? 'Congratulation' : 'Keep Trying!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: kQuizText,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                decoration: BoxDecoration(
                  color: good ? kQuizScoreGood : kQuizScoreBad,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: (good ? kQuizScoreGood : kQuizScoreBad)
                          .withValues(alpha: 0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  '$percent%',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: good ? kQuizText : Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'You scored ${quiz.score}/${quiz.totalQuestions}!',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total time: ${_formatDuration(quiz.totalTime)}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                good
                    ? "You've got a great foundation. Ready to try a different category?"
                    : "Don't give up! Practice makes perfect. Try again to improve your score.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<QuizProvider>().resetSession();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const CategorySelectionScreen(),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                  child: const Text('PLAY AGAIN'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
