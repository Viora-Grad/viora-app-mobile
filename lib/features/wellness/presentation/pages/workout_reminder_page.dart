import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/widgets/app_snackbar.dart';
import 'package:viora_app/features/wellness/presentation/cubits/workout_reminder_cubit.dart';

const _primary = Color(0xFF2F1193);
const _accent = Color(0xFFFF7043);

class WorkoutReminderPage extends StatelessWidget {
  const WorkoutReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkoutReminderCubit>()..load(),
      child: const _WorkoutReminderView(),
    );
  }
}

class _WorkoutReminderView extends StatelessWidget {
  const _WorkoutReminderView();

  String _fmt(BuildContext context, String hhmm) {
    final parts = hhmm.split(':');
    final t = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 0,
      minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );
    return t.format(context);
  }

  Future<void> _addTime(BuildContext context, WorkoutReminderCubit cubit) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked == null) return;
    final hhmm =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    await cubit.addTime(hhmm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Workout Break',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocListener<WorkoutReminderCubit, WorkoutReminderState>(
        listenWhen: (prev, curr) =>
            !prev.permissionDenied && curr.permissionDenied,
        listener: (context, state) {
          AppSnackBar.show(
            context,
            'Notifications are blocked. Enable them in system settings to get reminders.',
            type: AppSnackBarType.error,
          );
        },
        child: BlocBuilder<WorkoutReminderCubit, WorkoutReminderState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            final cubit = context.read<WorkoutReminderCubit>();
            final settings = state.settings;
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF7043), Color(0xFFF4511E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.fitness_center_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              settings.enabled
                                  ? 'Move breaks are on'
                                  : 'Move breaks are off',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Just 5 minutes to recharge your body.',
                              style: TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: _accent,
                    title: const Text(
                      'Enable workout reminders',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: settings.enabled,
                    onChanged: cubit.setEnabled,
                  ),
                ),
                const SizedBox(height: 24),
                Opacity(
                  opacity: settings.enabled ? 1 : 0.45,
                  child: IgnorePointer(
                    ignoring: !settings.enabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Reminder times',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _addTime(context, cubit),
                              icon: const Icon(Icons.add, color: _primary),
                              label: const Text(
                                'Add',
                                style: TextStyle(color: _primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (settings.times.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'No times yet. Tap "Add" to schedule a break.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          ...settings.times.map(
                            (t) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE8E8EE)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    color: _accent,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _fmt(context, t),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => cubit.removeTime(t),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () async {
                    await cubit.sendSample();
                    if (context.mounted) {
                      AppSnackBar.show(
                        context,
                        'Sample reminder sent!',
                        type: AppSnackBarType.success,
                      );
                    }
                  },
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('Send me a sample'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: const BorderSide(color: _primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
