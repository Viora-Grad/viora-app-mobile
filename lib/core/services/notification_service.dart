import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// A single daily reminder time (24h clock).
class ReminderSlot {
  final int hour;
  final int minute;

  const ReminderSlot(this.hour, this.minute);
}

/// Thin wrapper around [flutter_local_notifications] used by the wellness
/// features to schedule friendly, repeating daily reminders (water, workout).
///
/// Reminders are scheduled as a "series": each active time of day gets its own
/// notification id derived from a category [baseId], and repeats every day via
/// [DateTimeComponents.time]. Rescheduling first cancels the whole series so we
/// never leak stale reminders.
abstract class NotificationService {
  Future<void> init();

  /// Requests OS permission to post notifications. Returns `true` when granted
  /// (or when the platform does not require an explicit grant).
  Future<bool> requestPermission();

  /// (Re)schedules a repeating daily reminder series for a category.
  Future<void> scheduleDailySeries({
    required int baseId,
    required String channelId,
    required String channelName,
    required String channelDescription,
    required String title,
    required List<ReminderSlot> slots,
    required List<String> messages,
  });

  /// Cancels every reminder in a category's series.
  Future<void> cancelSeries(int baseId);

  /// Posts an immediate notification (used for "send me a sample" previews).
  Future<void> showNow({
    required String channelId,
    required String channelName,
    required String title,
    required String body,
  });
}

class NotificationServiceImpl implements NotificationService {
  NotificationServiceImpl(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  bool _initialized = false;

  /// Upper bound on reminders per category. A series never schedules more than
  /// this many slots, so [baseId] ranges must be spaced at least this far apart.
  static const int maxSlotsPerCategory = 24;

  @override
  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final localName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localName));
    } catch (_) {
      // Fall back to UTC if the device timezone can't be resolved; reminders
      // still fire, just anchored to UTC wall-clock times.
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? true;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  @override
  Future<void> scheduleDailySeries({
    required int baseId,
    required String channelId,
    required String channelName,
    required String channelDescription,
    required String title,
    required List<ReminderSlot> slots,
    required List<String> messages,
  }) async {
    await init();
    await cancelSeries(baseId);

    if (slots.isEmpty || messages.isEmpty) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final count = slots.length < maxSlotsPerCategory
        ? slots.length
        : maxSlotsPerCategory;

    for (var i = 0; i < count; i++) {
      final slot = slots[i];
      final message = messages[i % messages.length];
      await _plugin.zonedSchedule(
        baseId + i,
        title,
        message,
        _nextInstanceOf(slot.hour, slot.minute),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  @override
  Future<void> cancelSeries(int baseId) async {
    for (var i = 0; i < maxSlotsPerCategory; i++) {
      await _plugin.cancel(baseId + i);
    }
  }

  @override
  Future<void> showNow({
    required String channelId,
    required String channelName,
    required String title,
    required String body,
  }) async {
    await init();
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    // Fixed id so repeated previews replace each other instead of stacking.
    await _plugin.show(9999, title, body, details);
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
