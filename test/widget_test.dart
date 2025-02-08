// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:urcs/main.dart';
import 'package:urcs/providers/time_registration_provider.dart';

void main() {
  testWidgets('App should render without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TimeRegistrationProvider(),
        child: const MyApp(),
      ),
    );

    // Verify that the app starts with the login screen
    expect(find.text('URCS'), findsOneWidget);
  });
}
