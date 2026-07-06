import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/features/splash/representation/pages/splash.dart';
import 'package:viora_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full App -> BMI Calculator', () {
    testWidgets('launches real app, navigates to BMI, calculates 70kg/175cm',
        (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      expect(find.byType(SplashPage), findsOneWidget);

      final ctx = tester.element(find.byType(SplashPage));
      GoRouter.of(ctx).go(AppRoutes.bmiCalculator);
      await tester.pumpAndSettle();

      expect(find.text('Body Check'), findsOneWidget);
      expect(find.text('Check my result'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '70');
      await tester.enterText(find.byType(TextField).last, '175');
      await tester.tap(find.text('Check my result'));
      await tester.pumpAndSettle();

      expect(find.textContaining('22.9'), findsOneWidget);
      expect(find.textContaining('Healthy weight for you'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid weight',
        (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      GoRouter.of(tester.element(find.byType(SplashPage)))
          .go(AppRoutes.bmiCalculator);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '-5');
      await tester.enterText(find.byType(TextField).last, '175');
      await tester.tap(find.text('Check my result'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid weight in kg.'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid height',
        (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      GoRouter.of(tester.element(find.byType(SplashPage)))
          .go(AppRoutes.bmiCalculator);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '70');
      await tester.enterText(find.byType(TextField).last, '0');
      await tester.tap(find.text('Check my result'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid height in cm.'), findsOneWidget);
    });

    testWidgets('calculates with Female gender selected', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      GoRouter.of(tester.element(find.byType(SplashPage)))
          .go(AppRoutes.bmiCalculator);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Female'));
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, '60');
      await tester.enterText(find.byType(TextField).last, '165');
      await tester.tap(find.text('Check my result'));
      await tester.pumpAndSettle();

      expect(find.text('Healthy weight for you'), findsOneWidget);
    });
  });
}
