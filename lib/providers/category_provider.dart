import 'package:flutter/foundation.dart';

import '../models/trivia_category.dart';
import '../services/opentdb_service.dart';

enum CategoryLoadState { initial, loading, loaded, error }

class CategoryProvider extends ChangeNotifier {
  CategoryProvider({OpenTdbService? service})
      : _service = service ?? OpenTdbService();

  final OpenTdbService _service;

  List<TriviaCategory> _categories = [];
  CategoryLoadState _state = CategoryLoadState.initial;
  String? _error;

  List<TriviaCategory> get categories => List.unmodifiable(_categories);
  CategoryLoadState get state => _state;
  String? get error => _error;
  bool get hasCache => _categories.isNotEmpty;

  /// Loads once per session unless [force] is true.
  Future<void> loadCategories({bool force = false}) async {
    if (!force && _categories.isNotEmpty) {
      _state = CategoryLoadState.loaded;
      notifyListeners();
      return;
    }

    _state = CategoryLoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _categories = await _service.fetchCategories();
      _state = CategoryLoadState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = CategoryLoadState.error;
    }
    notifyListeners();
  }
}
