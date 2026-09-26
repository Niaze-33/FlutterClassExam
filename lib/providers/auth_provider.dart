import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import 'favorite_provider.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  FavoriteProvider? _favoriteProvider;

  User? _user;
  bool _isLoading = false;
  bool _isGuest = false;
  String? _error;

  AuthProvider({required AuthService authService}) : _authService = authService {
    _authService.authStateChanges.listen((user) async {
      final wasSignedOut = _user == null;
      _user = user;
      // If a real Firebase user signed in, we are no longer a guest
      if (user != null) {
        _isGuest = false;
      }
      notifyListeners();

      // When a new user signs in, reload their favorites
      if (user != null && wasSignedOut && _favoriteProvider != null) {
        await _favoriteProvider!.reloadForUser();
      }
      // When user signs out, clear favorites
      if (user == null && _favoriteProvider != null) {
        _favoriteProvider!.reloadForUser();
      }
    });
  }

  /// Call this once from the widget tree to wire up the FavoriteProvider.
  void bindFavoriteProvider(FavoriteProvider fp) {
    _favoriteProvider = fp;
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSignedIn => _user != null;
  bool get isGuest => _isGuest;
  bool get hasAccess => isSignedIn || _isGuest;

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  void continueAsGuest() {
    _isGuest = true;
    _error = null;
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _isGuest = false;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapFirebaseAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Sign in failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    _isLoading = true;
    _isGuest = false;
    _error = null;
    notifyListeners();

    try {
      await _authService.registerWithEmail(email, password, displayName: displayName);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapFirebaseAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _isGuest = false;
    _error = null;
    notifyListeners();
    try {
      await _authService.signOut();
    } catch (e) {
      debugPrint("Sign out error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password is too weak. Must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed. Please check your details.';
    }
  }
}
