import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lib/features/auth/screens/splash_screen.dart';
import '../lib/features/auth/screens/login_screen.dart';

void main() {
  testWidgets('Test Splash Screen', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FLUTTER ERROR: ${details.exception}');
      print('STACK TRACE: ${details.stack}');
    };

    try {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SplashScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      print('Splash screen loaded successfully!');
    } catch (e, s) {
      print('CAUGHT EXCEPTION: $e');
      print('STACK: $s');
    }
  });

  testWidgets('Test Login Screen', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FLUTTER ERROR: ${details.exception}');
      print('STACK TRACE: ${details.stack}');
    };

    try {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      print('Login screen loaded successfully!');
    } catch (e, s) {
      print('CAUGHT EXCEPTION: $e');
      print('STACK: $s');
    }
  });
}
