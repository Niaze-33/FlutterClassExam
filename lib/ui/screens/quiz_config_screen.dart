import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/quiz_constants.dart';
import '../../core/quiz_theme.dart';
import '../../providers/quiz_provider.dart';
import '../widgets/quiz_widgets.dart';
import 'quiz_screen.dart';

class QuizConfigScreen extends StatefulWidget {
  const QuizConfigScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final int categoryId;
  final String categoryName;

  @override
  State<QuizConfigScreen> createState() => _QuizConfigScreenState();
}

class _QuizConfigScreenState extends State<QuizConfigScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quiz = context.read<QuizProvider>();
      quiz.setCategory(id: widget.categoryId, name: widget.categoryName);
    });
  }

  Future<void> _start() async {
    final quiz = context.read<QuizProvider>();
    final ok = await quiz.startQuiz();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const QuizScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final isLoading = quiz.phase == QuizPhase.loading;
    final hasError = quiz.phase == QuizPhase.error;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Configuration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (hasError && quiz.error != null)
              RetryBanner(
                message: quiz.error!,
                onRetry: _start,
              ),
            Expanded(
              child: isLoading
                  ? const QuizLoadingSkeleton()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                          Text(
                            'Quizzical',
                            style: GoogleFonts.poppins(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: kQuizText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Configuration',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.categoryName,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 36),
                          _AmountSlider(
                            value: quiz.amount.toDouble(),
                            onChanged: (v) => quiz.setAmount(v.round()),
                          ),
                          const SizedBox(height: 20),
                          _LabeledDropdown<String>(
                            label: 'Difficulty',
                            value: quiz.difficulty,
                            items: const [
                              DropdownMenuItem(value: 'any', child: Text('Any')),
                              DropdownMenuItem(value: 'easy', child: Text('Easy')),
                              DropdownMenuItem(
                                  value: 'medium', child: Text('Medium')),
                              DropdownMenuItem(value: 'hard', child: Text('Hard')),
                            ],
                            onChanged: (v) {
                              if (v != null) quiz.setDifficulty(v);
                            },
                          ),
                          const SizedBox(height: 16),
                          _LabeledDropdown<String>(
                            label: 'Type',
                            value: quiz.type,
                            items: const [
                              DropdownMenuItem(
                                  value: 'multiple', child: Text('Multiple')),
                              DropdownMenuItem(
                                  value: 'boolean', child: Text('True / False')),
                            ],
                            onChanged: (v) {
                              if (v != null) quiz.setType(v);
                            },
                          ),
                          const Spacer(flex: 3),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _start,
                              child: const Text('START'),
                            ),
                          ),
                          const SizedBox(height: 20),
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

class _AmountSlider extends StatelessWidget {
  const _AmountSlider({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Amount',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            Text(
              '${value.round()}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: kQuizPrimary,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: kMinQuestionAmount.toDouble(),
          max: kMaxQuestionAmount.toDouble(),
          divisions: kMaxQuestionAmount - kMinQuestionAmount,
          activeColor: kQuizPrimary,
          label: '${value.round()}',
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _LabeledDropdown<T> extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: kQuizBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
