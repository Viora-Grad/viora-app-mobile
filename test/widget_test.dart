import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/features/splash/representation/pages/splash.dart';
import 'package:viora_app/features/splash/representation/widgets/logo_widget.dart';
import 'package:viora_app/main_dev.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dependencyInjection();
  });

  group('MyApp widget tests', () {
    testWidgets('renders MaterialApp', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('renders SplashPage as the home screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(SplashPage), findsOneWidget);
    });

    testWidgets('starts the splash logo flow after the first frame', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      expect(find.byType(LogoWidget), findsOneWidget);
    });

    testWidgets('[CI CHECK] app builds and renders without error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });
  });
}
