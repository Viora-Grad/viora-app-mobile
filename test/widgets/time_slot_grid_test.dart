import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viora_app/features/appointments/domain/entities/available_slot.dart';
import 'package:viora_app/features/appointments/representation/widgets/time_slot_grid.dart';

void main() {
  testWidgets('TimeSlotGrid shows empty state when no slots', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: TimeSlotGrid(slots: const [])),
    ));

    expect(find.text('No available slots'), findsOneWidget);
  });

  testWidgets('TimeSlotGrid shows slots and triggers onSlotSelected', (tester) async {
    final slot = AvailableSlot(
      startTime: DateTime(2024, 7, 6, 9, 0),
      endTime: DateTime(2024, 7, 6, 9, 30),
    );
    AvailableSlot? tapped;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TimeSlotGrid(
          slots: [slot],
          onSlotSelected: (s) => tapped = s,
        ),
      ),
    ));

    expect(find.textContaining('slot'), findsOneWidget);
    await tester.tap(find.text('${slot.formattedStart} - ${slot.formattedEnd}'));
    await tester.pumpAndSettle();

    expect(tapped, isNotNull);
    expect(tapped!.startTime.hour, equals(9));
  });
}
