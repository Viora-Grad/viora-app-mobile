import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/core/services/notification_service.dart';
import 'package:viora_app/features/wellness/data/wellness_local.dart';
import 'package:viora_app/features/wellness/domain/reminder_messages.dart';
import 'package:viora_app/features/wellness/domain/workout_reminder_settings.dart';

class WorkoutReminderState extends Equatable {
  final WorkoutReminderSettings settings;
  final bool loading;
  final bool permissionDenied;

  const WorkoutReminderState({
    this.settings = const WorkoutReminderSettings(),
    this.loading = true,
    this.permissionDenied = false,
  });

  WorkoutReminderState copyWith({
    WorkoutReminderSettings? settings,
    bool? loading,
    bool? permissionDenied,
  }) {
    return WorkoutReminderState(
      settings: settings ?? this.settings,
      loading: loading ?? this.loading,
      permissionDenied: permissionDenied ?? this.permissionDenied,
    );
  }

  @override
  List<Object?> get props => [settings, loading, permissionDenied];
}

class WorkoutReminderCubit extends Cubit<WorkoutReminderState> {
  WorkoutReminderCubit(this._local, this._notifications)
    : super(const WorkoutReminderState());

  final WellnessLocal _local;
  final NotificationService _notifications;

  static const int baseId = 2000;
  static const String channelId = 'wellness_workout';
  static const String channelName = 'Workout Reminders';
  static const String channelDescription =
      'Vivi nudges to take a quick 5-minute movement break.';

  Future<void> load() async {
    final settings = await _local.getWorkoutSettings();
    emit(WorkoutReminderState(settings: settings, loading: false));
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

  Future<void> addTime(String time) async {
    if (state.settings.times.contains(time)) return;
    final times = [...state.settings.times, time]..sort();
    await _update(state.settings.copyWith(times: times));
  }

  Future<void> removeTime(String time) async {
    final times = state.settings.times.where((t) => t != time).toList();
    await _update(state.settings.copyWith(times: times));
  }

  Future<void> sendSample() async {
    await _notifications.showNow(
      channelId: channelId,
      channelName: channelName,
      title: 'Vivi 💪',
      body: ReminderMessages.workout.first,
    );
  }

  Future<void> _update(WorkoutReminderSettings settings) async {
    await _local.saveWorkoutSettings(settings);
    await _reschedule(settings);
    emit(state.copyWith(settings: settings, permissionDenied: false));
  }

  Future<void> _reschedule(WorkoutReminderSettings settings) async {
    if (settings.enabled) {
      await _notifications.scheduleDailySeries(
        baseId: baseId,
        channelId: channelId,
        channelName: channelName,
        channelDescription: channelDescription,
        title: 'Vivi 💪',
        slots: settings.slots,
        messages: ReminderMessages.workout,
      );
    } else {
      await _notifications.cancelSeries(baseId);
    }
  }
}
