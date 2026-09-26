// ignore_for_file: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/repositories/user_repository.dart';

class MockFirebasePlatform extends FirebasePlatform {
  MockFirebasePlatform() : super();

  final Map<String, FirebaseAppPlatform> _apps = {};

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    if (_apps.containsKey(name)) {
      return _apps[name]!;
    }
    final defaultApp = FirebaseAppPlatform(name, const FirebaseOptions(
      apiKey: 'testKey',
      appId: 'testAppId',
      messagingSenderId: 'testSenderId',
      projectId: 'testProjectId',
    ));
    _apps[name] = defaultApp;
    return defaultApp;
  }

  @override
  List<FirebaseAppPlatform> get apps => _apps.values.toList();

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    final appName = name ?? defaultFirebaseAppName;
    final app = FirebaseAppPlatform(
      appName,
      options ?? const FirebaseOptions(
        apiKey: 'testKey',
        appId: 'testAppId',
        messagingSenderId: 'testSenderId',
        projectId: 'testProjectId',
      ),
    );
    _apps[appName] = app;
    return app;
  }
}

class MockUserRepository implements UserRepository {
  final Set<String> _favs = {};

  @override
  Future<List<String>> getFavorites() async => _favs.toList();

  @override
  Future<void> addFavorite(String recipeId) async {
    _favs.add(recipeId);
  }

  @override
  Future<void> removeFavorite(String recipeId) async {
    _favs.remove(recipeId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> initMockFirebase() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebasePlatform.instance = MockFirebasePlatform();
  await Firebase.initializeApp();
}
