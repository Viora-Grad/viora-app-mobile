import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viora_app/features/appointments/representation/widgets/day_picker.dart';

void main() {
  testWidgets('DayPickerWidget shows days and calls callback on tap', (tester) async {
    final today = DateTime.now();
    DateTime? selected;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DayPickerWidget(
          selectedDate: today,
          onDateSelected: (d) => selected = d,
        ),
      ),
    ));

    // Ensure the ListView is present and contains at least one day label
    expect(find.byType(ListView), findsOneWidget);

    // Tap the second day tile
    final tiles = find.byType(GestureDetector);
    expect(tiles, findsWidgets);
    await tester.tap(tiles.at(1));
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
    expect(selected!.difference(today).inDays, greaterThanOrEqualTo(1));
  });
}
