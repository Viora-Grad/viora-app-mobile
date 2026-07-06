import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:viora_app/core/services/notification_service.dart';

/// Educational unit tests for `NotificationServiceImpl`.
///
/// This demonstrates how to stub a plugin and assert interactions like
/// scheduling and cancelling. We rely on a lightweight `Mock` implementation
/// to avoid platform channels while keeping behavior deterministic.

import 'dart:io';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class FakeTZDateTime extends Fake implements tz.TZDateTime {}

void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late NotificationServiceImpl subject;

  setUpAll(() {
    registerFallbackValue(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ));
    registerFallbackValue(FakeTZDateTime());
    registerFallbackValue(UILocalNotificationDateInterpretation.absoluteTime);
    registerFallbackValue(const NotificationDetails(
      android: AndroidNotificationDetails('c', 'n'),
    ));
  });

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    subject = NotificationServiceImpl(mockPlugin);

    when(() => mockPlugin.initialize(
      any(),
      onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'),
      onDidReceiveBackgroundNotificationResponse: any(named: 'onDidReceiveBackgroundNotificationResponse'),
    )).thenAnswer((_) async => true);
    // FlutterTimezone.getLocalTimezone will throw in test. Fallback to UTC.
    when(() => mockPlugin.cancel(any())).thenAnswer((_) async {});
    when(() => mockPlugin.zonedSchedule(
      any(), any(), any(), any(), any(),
      androidScheduleMode: any(named: 'androidScheduleMode'),
      uiLocalNotificationDateInterpretation: any(named: 'uiLocalNotificationDateInterpretation'),
      matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
    )).thenAnswer((_) async {});
    when(() => mockPlugin.show(any(), any(), any(), any())).thenAnswer((_) async {});
  });

  test('scheduleDailySeries does nothing when slots or messages empty', () async {
    await subject.scheduleDailySeries(
      baseId: 100,
      channelId: 'c',
      channelName: 'n',
      channelDescription: 'd',
      title: 't',
      slots: const [],
      messages: const ['m'],
    );

    // zonedSchedule must not be called when slots empty.
    verifyNever(() => mockPlugin.zonedSchedule(any(), any(), any(), any(), any(),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        uiLocalNotificationDateInterpretation:
            any(named: 'uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents')));

    await subject.scheduleDailySeries(
      baseId: 100,
      channelId: 'c',
      channelName: 'n',
      channelDescription: 'd',
      title: 't',
      slots: const [ReminderSlot(9, 0)],
      messages: const [],
    );

    // zonedSchedule must not be called when messages empty.
    verifyNever(() => mockPlugin.zonedSchedule(any(), any(), any(), any(), any(),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        uiLocalNotificationDateInterpretation:
            any(named: 'uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents')));
  });

  test('scheduleDailySeries caps scheduled notifications at maxSlotsPerCategory', () async {
    final slots = List.generate(30, (i) => ReminderSlot(i % 24, 0));
    final messages = List.generate(2, (i) => 'msg_$i');

    await subject.scheduleDailySeries(
      baseId: 200,
      channelId: 'c',
      channelName: 'n',
      channelDescription: 'd',
      title: 't',
      slots: slots,
      messages: messages,
    );

    // verify zonedSchedule called up to the configured max
    verify(() => mockPlugin.zonedSchedule(any(), any(), any(), any(), any(),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        uiLocalNotificationDateInterpretation:
            any(named: 'uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents')))
        .called(NotificationServiceImpl.maxSlotsPerCategory);

    // Scheduling always cancels the previous series first: ensure cancel was called many times
    verify(() => mockPlugin.cancel(any())).called(NotificationServiceImpl.maxSlotsPerCategory);
  });
}
