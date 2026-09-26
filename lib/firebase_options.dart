// File generated for FlutterMegaProject targeting project: appdevelopmentcourse-6ee51
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBDJ2QvG5KhNYrx_qchNgyUC4zY7kKwoyM',
    appId: '1:663618775537:web:55f27daa521c2adeea3c50',
    messagingSenderId: '663618775537',
    projectId: 'appdevelopmentcourse-6ee51',
    authDomain: 'appdevelopmentcourse-6ee51.firebaseapp.com',
    storageBucket: 'appdevelopmentcourse-6ee51.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBDJ2QvG5KhNYrx_qchNgyUC4zY7kKwoyM',
    appId: '1:663618775537:android:55f27daa521c2adeea3c50',
    messagingSenderId: '663618775537',
    projectId: 'appdevelopmentcourse-6ee51',
    storageBucket: 'appdevelopmentcourse-6ee51.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBDJ2QvG5KhNYrx_qchNgyUC4zY7kKwoyM',
    appId: '1:663618775537:ios:55f27daa521c2adeea3c50',
    messagingSenderId: '663618775537',
    projectId: 'appdevelopmentcourse-6ee51',
    storageBucket: 'appdevelopmentcourse-6ee51.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBDJ2QvG5KhNYrx_qchNgyUC4zY7kKwoyM',
    appId: '1:663618775537:ios:55f27daa521c2adeea3c50',
    messagingSenderId: '663618775537',
    projectId: 'appdevelopmentcourse-6ee51',
    storageBucket: 'appdevelopmentcourse-6ee51.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBDJ2QvG5KhNYrx_qchNgyUC4zY7kKwoyM',
    appId: '1:663618775537:web:55f27daa521c2adeea3c50',
    messagingSenderId: '663618775537',
    projectId: 'appdevelopmentcourse-6ee51',
    authDomain: 'appdevelopmentcourse-6ee51.firebaseapp.com',
    storageBucket: 'appdevelopmentcourse-6ee51.firebasestorage.app',
  );
}
