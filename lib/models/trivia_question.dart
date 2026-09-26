String decodeHtmlEntities(String value) {
  return value
      .replaceAll('&quot;', '"')
      .replaceAll('&#039;', "'")
      .replaceAll('&apos;', "'")
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', ' ')
      .replaceAllMapped(RegExp(r'&#(\d+);'), (m) {
        return String.fromCharCode(int.parse(m.group(1)!));
      })
      .replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (m) {
        return String.fromCharCode(int.parse(m.group(1)!, radix: 16));
      });
}

class TriviaQuestion {
  TriviaQuestion({
    required this.type,
    required this.difficulty,
    required this.category,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.shuffledAnswers,
  });

  final String type;
  final String difficulty;
  final String category;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final List<String> shuffledAnswers;

  bool get isBoolean => type == 'boolean';

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) {
    final correct = decodeHtmlEntities(json['correct_answer'] as String);
    final incorrect = (json['incorrect_answers'] as List<dynamic>)
        .map((e) => decodeHtmlEntities(e as String))
        .toList();
    final all = [...incorrect, correct]..shuffle();

    return TriviaQuestion(
      type: json['type'] as String,
      difficulty: json['difficulty'] as String,
      category: decodeHtmlEntities(json['category'] as String),
      question: decodeHtmlEntities(json['question'] as String),
      correctAnswer: correct,
      incorrectAnswers: incorrect,
      shuffledAnswers: all,
    );
  }
}
