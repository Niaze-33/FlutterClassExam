import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/quiz_constants.dart';
import '../models/trivia_question.dart';
import '../services/opentdb_service.dart';

enum QuizPhase { idle, loading, playing, answered, finished, error }

class QuizProvider extends ChangeNotifier {
  QuizProvider({OpenTdbService? service})
      : _service = service ?? OpenTdbService();

  final OpenTdbService _service;

  int amount = kDefaultQuestionAmount;
  String difficulty = 'any'; // any | easy | medium | hard
  String type = 'multiple'; // multiple | boolean
  int? categoryId;
  String categoryName = '';

  List<TriviaQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _timedOut = false;
  QuizPhase _phase = QuizPhase.idle;
  String? _error;

  Timer? _timer;
  int _secondsLeft = kQuestionTimerSeconds;
  DateTime? _sessionStartedAt;
  Duration _totalTime = Duration.zero;

  List<TriviaQuestion> get questions => List.unmodifiable(_questions);
  int get currentIndex => _currentIndex;
  int get score => _score;
  String? get selectedAnswer => _selectedAnswer;
  bool get timedOut => _timedOut;
  QuizPhase get phase => _phase;
  String? get error => _error;
  int get secondsLeft => _secondsLeft;
  Duration get totalTime => _totalTime;
  int get totalQuestions => _questions.length;

  TriviaQuestion? get currentQuestion =>
      _questions.isEmpty || _currentIndex >= _questions.length
          ? null
          : _questions[_currentIndex];

  double get progress =>
      totalQuestions == 0 ? 0 : (_currentIndex + 1) / totalQuestions;

  double get accuracyPercent =>
      totalQuestions == 0 ? 0 : (_score / totalQuestions) * 100;

  bool get isLastQuestion =>
      _questions.isNotEmpty && _currentIndex >= _questions.length - 1;

  Future<void> loadSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    amount = prefs.getInt(kPrefsAmount) ?? kDefaultQuestionAmount;
    difficulty = prefs.getString(kPrefsDifficulty) ?? 'any';
    type = prefs.getString(kPrefsType) ?? 'multiple';
    categoryId = prefs.getInt(kPrefsCategoryId);
    categoryName = prefs.getString(kPrefsCategoryName) ?? '';
    notifyListeners();
  }

  Future<void> saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kPrefsAmount, amount);
    await prefs.setString(kPrefsDifficulty, difficulty);
    await prefs.setString(kPrefsType, type);
    if (categoryId != null) {
      await prefs.setInt(kPrefsCategoryId, categoryId!);
    }
    await prefs.setString(kPrefsCategoryName, categoryName);
  }

  void setCategory({required int id, required String name}) {
    categoryId = id;
    categoryName = name;
    notifyListeners();
  }

  void setAmount(int value) {
    amount = value.clamp(kMinQuestionAmount, kMaxQuestionAmount);
    notifyListeners();
  }

  void setDifficulty(String value) {
    difficulty = value;
    notifyListeners();
  }

  void setType(String value) {
    type = value;
    notifyListeners();
  }

  Future<bool> startQuiz() async {
    if (categoryId == null) {
      _error = 'No category selected';
      _phase = QuizPhase.error;
      notifyListeners();
      return false;
    }

    _phase = QuizPhase.loading;
    _error = null;
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _timedOut = false;
    _totalTime = Duration.zero;
    notifyListeners();

    await saveConfig();

    try {
      _questions = await _service.fetchQuestions(
        amount: amount,
        categoryId: categoryId!,
        difficulty: difficulty,
        type: type,
      );
      if (_questions.isEmpty) {
        throw OpenTdbException('No questions returned. Try different settings.');
      }
      _sessionStartedAt = DateTime.now();
      _phase = QuizPhase.playing;
      _startTimer();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _phase = QuizPhase.error;
      notifyListeners();
      return false;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = kQuestionTimerSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        _secondsLeft = 0;
        _onTimeout();
      } else {
        _secondsLeft--;
        notifyListeners();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onTimeout() {
    if (_phase != QuizPhase.playing) return;
    _timedOut = true;
    _selectedAnswer = null;
    _phase = QuizPhase.answered;
    notifyListeners();
    // Auto-advance after a short pause so user sees timeout state
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_phase == QuizPhase.answered && _timedOut) {
        nextQuestion();
      }
    });
  }

  void selectAnswer(String answer) {
    if (_phase != QuizPhase.playing) return;
    _stopTimer();
    _selectedAnswer = answer;
    _timedOut = false;
    final q = currentQuestion;
    if (q != null && answer == q.correctAnswer) {
      _score++;
    }
    _phase = QuizPhase.answered;
    notifyListeners();
  }

  bool isCorrectAnswer(String answer) {
    final q = currentQuestion;
    return q != null && answer == q.correctAnswer;
  }

  void nextQuestion() {
    _stopTimer();
    if (isLastQuestion) {
      _finish();
      return;
    }
    _currentIndex++;
    _selectedAnswer = null;
    _timedOut = false;
    _phase = QuizPhase.playing;
    _startTimer();
    notifyListeners();
  }

  void _finish() {
    _stopTimer();
    if (_sessionStartedAt != null) {
      _totalTime = DateTime.now().difference(_sessionStartedAt!);
    }
    _phase = QuizPhase.finished;
    notifyListeners();
  }

  /// Clears active quiz session but keeps last config (amount/difficulty/type/category).
  void resetSession() {
    _stopTimer();
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _timedOut = false;
    _phase = QuizPhase.idle;
    _error = null;
    _secondsLeft = kQuestionTimerSeconds;
    _sessionStartedAt = null;
    _totalTime = Duration.zero;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    if (_phase == QuizPhase.error) {
      _phase = QuizPhase.idle;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
