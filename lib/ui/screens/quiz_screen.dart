import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/quiz_theme.dart';
import '../../providers/quiz_provider.dart';
import 'category_selection_screen.dart';
import 'results_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  QuizProvider? _quiz;
  bool _navigatedToResults = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final quiz = context.read<QuizProvider>();
    if (_quiz != quiz) {
      _quiz?.removeListener(_onQuizChanged);
      _quiz = quiz;
      _quiz!.addListener(_onQuizChanged);
    }
  }

  void _onQuizChanged() {
    if (!mounted || _navigatedToResults) return;
    if (_quiz?.phase == QuizPhase.finished) {
      _navigatedToResults = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResultsScreen()),
        );
      });
    }
  }

  @override
  void dispose() {
    _quiz?.removeListener(_onQuizChanged);
    super.dispose();
  }

  Future<void> _exit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit quiz?'),
        content: const Text('Your progress for this session will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      context.read<QuizProvider>().resetSession();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CategorySelectionScreen()),
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final question = quiz.currentQuestion;

    return Scaffold(
      backgroundColor: kQuizBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                children: [
                  const Spacer(),
                  Text(
                    '${quiz.currentIndex + 1}/${quiz.totalQuestions}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _exit,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('EXIT'),
                    style: TextButton.styleFrom(foregroundColor: kQuizText),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: quiz.progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade300,
                      color: kQuizPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Score: ${quiz.score}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 18,
                            color: quiz.secondsLeft <= 5
                                ? Colors.red
                                : kQuizPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${quiz.secondsLeft}s',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: quiz.secondsLeft <= 5
                                  ? Colors.red
                                  : kQuizText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (question == null)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          question.question,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            height: 1.35,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.separated(
                          itemCount: question.shuffledAnswers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final answer = question.shuffledAnswers[index];
                            return _AnswerTile(
                              answer: answer,
                              selected: quiz.selectedAnswer,
                              showResult: quiz.phase == QuizPhase.answered,
                              isCorrect: quiz.isCorrectAnswer(answer),
                              timedOut: quiz.timedOut,
                              onTap: () => quiz.selectAnswer(answer),
                            );
                          },
                        ),
                      ),
                      if (quiz.phase == QuizPhase.answered && !quiz.timedOut)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16, top: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kQuizPrimaryDark,
                              ),
                              onPressed: quiz.nextQuestion,
                              child: Text(
                                quiz.isLastQuestion ? 'See Results' : 'Next',
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.answer,
    required this.selected,
    required this.showResult,
    required this.isCorrect,
    required this.timedOut,
    required this.onTap,
  });

  final String answer;
  final String? selected;
  final bool showResult;
  final bool isCorrect;
  final bool timedOut;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == answer;

    Color bg = Colors.white;
    Color fg = Colors.black87;
    Widget trailing = Icon(
      Icons.radio_button_unchecked,
      color: Colors.grey.shade400,
    );

    if (showResult) {
      if (isSelected && !isCorrect) {
        bg = kQuizIncorrectBg;
        trailing = const Icon(Icons.cancel, color: Colors.red);
      } else if (isCorrect && (isSelected || timedOut)) {
        bg = kQuizCorrectBg;
        fg = kQuizPrimaryDark;
        trailing = const Icon(Icons.check_circle, color: kQuizPrimaryDark);
      } else if (isSelected) {
        bg = kQuizCorrectBg;
        fg = kQuizPrimaryDark;
        trailing = const Icon(Icons.check_circle, color: kQuizPrimaryDark);
      }
    } else if (isSelected) {
      bg = kQuizCorrectBg;
      fg = kQuizPrimaryDark;
      trailing = const Icon(Icons.check_circle, color: kQuizPrimaryDark);
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: showResult ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  answer,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: fg,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
