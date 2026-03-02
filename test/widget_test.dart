import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viora_app/main.dart';

void main() {
  group('MyApp widget tests', () {
    testWidgets('renders app title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.text('Viora Home Page'), findsOneWidget);
    });

    testWidgets('renders welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.text('Welcome to Viora App!'), findsOneWidget);
    });

    testWidgets('renders MaterialApp', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('renders AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('[CI CHECK] app builds and renders without error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
