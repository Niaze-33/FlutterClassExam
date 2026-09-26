import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/trivia_category.dart';
import '../models/trivia_question.dart';

class OpenTdbException implements Exception {
  OpenTdbException(this.message);
  final String message;

  @override
  String toString() => message;
}

class OpenTdbService {
  OpenTdbService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _categoriesUrl = 'https://opentdb.com/api_category.php';
  static const _questionsBase = 'https://opentdb.com/api.php';

  Future<List<TriviaCategory>> fetchCategories() async {
    final response = await _client.get(Uri.parse(_categoriesUrl));
    if (response.statusCode != 200) {
      throw OpenTdbException('Failed to load categories (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['trivia_categories'] as List<dynamic>? ?? [];
    return list
        .map((e) => TriviaCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// [difficulty] null or empty means Any (omit param).
  /// [type] null or empty means Any (omit param).
  Future<List<TriviaQuestion>> fetchQuestions({
    required int amount,
    required int categoryId,
    String? difficulty,
    String? type,
  }) async {
    final params = <String, String>{
      'amount': amount.toString(),
      'category': categoryId.toString(),
    };
    if (difficulty != null && difficulty.isNotEmpty && difficulty != 'any') {
      params['difficulty'] = difficulty;
    }
    if (type != null && type.isNotEmpty && type != 'any') {
      params['type'] = type;
    }

    final uri = Uri.parse(_questionsBase).replace(queryParameters: params);
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw OpenTdbException('Failed to load questions (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final code = data['response_code'] as int? ?? -1;
    if (code != 0) {
      throw OpenTdbException(_messageForCode(code));
    }

    final results = data['results'] as List<dynamic>? ?? [];
    return results
        .map((e) => TriviaQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String _messageForCode(int code) {
    switch (code) {
      case 1:
        return 'Not enough questions for this config. Try fewer questions or different filters.';
      case 2:
        return 'Invalid quiz parameters. Please adjust and try again.';
      default:
        return 'Could not load questions (code $code). Please retry.';
    }
  }
}
