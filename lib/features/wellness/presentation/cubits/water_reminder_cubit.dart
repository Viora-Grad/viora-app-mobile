import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/core/services/notification_service.dart';
import 'package:viora_app/features/wellness/data/wellness_local.dart';
import 'package:viora_app/features/wellness/domain/reminder_messages.dart';
import 'package:viora_app/features/wellness/domain/water_reminder_settings.dart';

class WaterReminderState extends Equatable {
  final WaterReminderSettings settings;
  final bool loading;
  final bool permissionDenied;

  const WaterReminderState({
    this.settings = const WaterReminderSettings(),
    this.loading = true,
    this.permissionDenied = false,
  });

  WaterReminderState copyWith({
    WaterReminderSettings? settings,
    bool? loading,
    bool? permissionDenied,
  }) {
    return WaterReminderState(
      settings: settings ?? this.settings,
      loading: loading ?? this.loading,
      permissionDenied: permissionDenied ?? this.permissionDenied,
    );
  }

  @override
  List<Object?> get props => [settings, loading, permissionDenied];
}

class WaterReminderCubit extends Cubit<WaterReminderState> {
  WaterReminderCubit(this._local, this._notifications)
    : super(const WaterReminderState());

  final WellnessLocal _local;
  final NotificationService _notifications;

  static const int baseId = 1000;
  static const String channelId = 'wellness_water';
  static const String channelName = 'Water Reminders';
  static const String channelDescription =
      'Gentle nudges from Vivi to stay hydrated.';

  Future<void> load() async {
    final settings = await _local.getWaterSettings();
    emit(WaterReminderState(settings: settings, loading: false));
  }

  Future<void> setEnabled(bool value) async {
    if (value) {
      final granted = await _notifications.requestPermission();
      if (!granted) {
        emit(state.copyWith(permissionDenied: true));
        return;
      }
    }
    await _update(state.settings.copyWith(enabled: value));
  }

  Future<void> setInterval(int hours) =>
      _update(state.settings.copyWith(intervalHours: hours));

  Future<void> setWindow({required int startHour, required int endHour}) =>
      _update(state.settings.copyWith(startHour: startHour, endHour: endHour));

  Future<void> sendSample() async {
    await _notifications.showNow(
      channelId: channelId,
      channelName: channelName,
      title: 'Vivi 💧',
      body: ReminderMessages.water.first,
    );
  }

  Future<void> _update(WaterReminderSettings settings) async {
    await _local.saveWaterSettings(settings);
    await _reschedule(settings);
    emit(state.copyWith(settings: settings, permissionDenied: false));
  }

  Future<void> _reschedule(WaterReminderSettings settings) async {
    if (settings.enabled) {
      await _notifications.scheduleDailySeries(
        baseId: baseId,
        channelId: channelId,
        channelName: channelName,
        channelDescription: channelDescription,
        title: 'Vivi 💧',
        slots: settings.slots,
        messages: ReminderMessages.water,
      );
    } else {
      await _notifications.cancelSeries(baseId);
    }
  }
}
