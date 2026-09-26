import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/providers/auth_provider.dart';
import 'package:recipe_app/providers/favorite_provider.dart';
import 'package:recipe_app/providers/quantity_provider.dart';
import 'package:recipe_app/providers/review_provider.dart';
import 'package:recipe_app/repositories/review_repository.dart';
import 'package:recipe_app/services/auth_service.dart';
import 'package:recipe_app/ui/screens/recipe_details_screen.dart';
import 'package:recipe_app/ui/widgets/quantity_increment_decrement.dart';
import 'test_helper.dart';

// 1x1 transparent PNG
final Uint8List _kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
]);

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _TestHttpClient();
}

class _TestHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) => Future.value(_TestHttpClientRequest());
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) => Future.value(_TestHttpClientRequest());
  @override
  void close({bool force = false}) {}
}

class _TestHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  final HttpHeaders headers = _TestHttpHeaders();

  @override
  Future<HttpClientResponse> close() => Future.value(_TestHttpClientResponse());
}

class _TestHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  List<String>? operator [](String name) => null;
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _TestHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  int get statusCode => 200;
  @override
  int get contentLength => _kTransparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;
  @override
  HttpHeaders get headers => _TestHttpHeaders();

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  setUpAll(() async {
    HttpOverrides.global = _TestHttpOverrides();
    await initMockFirebase();
  });

  final testRecipe = Recipe(
    id: "test-1",
    name: "Beef Steak",
    image: "https://images.unsplash.com/photo-1600891964092-4316c288032e",
    category: "Dinner",
    calories: 140,
    time: 25,
    rating: 4.5,
    reviews: 20,
    description: "A delicious grilled beef steak.",
    instructions: [
      "Season the meat generously.",
      "Sear in a hot pan for 4 minutes per side.",
      "Rest before slicing."
    ],
    ingredients: [
      Ingredient(name: "Beef", image: "https://example.com/beef.jpg", baseAmount: 400),
      Ingredient(name: "Vegetables", image: "https://example.com/veg.jpg", baseAmount: 100),
    ],
  );

  Widget createTestWidget() {
    final authService = AuthService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService: authService)),
        ChangeNotifierProvider(create: (_) => FavoriteProvider(repository: MockUserRepository())),
        ChangeNotifierProvider(create: (_) => QuantityProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider(repository: ReviewRepository(authService: authService))),
      ],
      child: MaterialApp(
        home: RecipeDetailsScreen(recipe: testRecipe),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('RecipeDetailsScreen renders all key elements correctly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await settle(tester);

    // Title
    expect(find.text("Beef Steak"), findsOneWidget);

    // Cooking information
    expect(find.text("140 Cal"), findsOneWidget);
    expect(find.text("25 Min"), findsOneWidget);
    expect(find.text("4.5"), findsOneWidget);

    // Initial Servings should be 1
    expect(find.descendant(of: find.byType(QuantityIncrementDecrement), matching: find.text("1")), findsOneWidget);

    // Ingredients section header
    expect(find.text("Ingredients"), findsWidgets);

    // Initial ingredient amounts for 1 serving
    expect(find.text("400.0g"), findsOneWidget);
    expect(find.text("100.0g"), findsOneWidget);

    // Tab Bar
    expect(find.text("Instructions"), findsOneWidget);

    // Tap Instructions tab
    await tester.tap(find.text("Instructions"));
    await settle(tester);

    // Instructions steps
    expect(find.text("Season the meat generously."), findsOneWidget);
    expect(find.text("Sear in a hot pan for 4 minutes per side."), findsOneWidget);
    expect(find.text("Rest before slicing."), findsOneWidget);

    // Start Cooking FAB
    expect(find.text("Start Cooking"), findsOneWidget);
  });

  testWidgets('Servings stepper increases quantity and scales ingredient amounts',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await settle(tester);

    expect(find.descendant(of: find.byType(QuantityIncrementDecrement), matching: find.text("1")), findsOneWidget);
    expect(find.text("400.0g"), findsOneWidget);

    // Tap plus button
    await tester.tap(find.byIcon(Iconsax.add));
    await settle(tester);

    // Servings becomes 2
    expect(find.descendant(of: find.byType(QuantityIncrementDecrement), matching: find.text("2")), findsOneWidget);
    // 400 * 2 = 800.0g
    expect(find.text("800.0g"), findsOneWidget);
    // 100 * 2 = 200.0g
    expect(find.text("200.0g"), findsOneWidget);

    // Tap minus button
    await tester.tap(find.byIcon(Iconsax.minus));
    await settle(tester);

    // Returns to 400.0g
    expect(find.text("400.0g"), findsOneWidget);
  });

  testWidgets('Favorite button toggles favorite state',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await settle(tester);

    // Initially not favorite
    expect(find.byIcon(Iconsax.heart), findsOneWidget);
    expect(find.byIcon(Iconsax.heart5), findsNothing);

    // Tap favorite button
    await tester.tap(find.byIcon(Iconsax.heart));
    await settle(tester);

    // Should now be favorite
    expect(find.byIcon(Iconsax.heart5), findsOneWidget);

    // Tap again to unfavorite
    await tester.tap(find.byIcon(Iconsax.heart5));
    await settle(tester);

    expect(find.byIcon(Iconsax.heart), findsOneWidget);
  });
}
