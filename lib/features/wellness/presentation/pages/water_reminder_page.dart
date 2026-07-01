import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/widgets/app_snackbar.dart';
import 'package:viora_app/features/wellness/domain/water_reminder_settings.dart';
import 'package:viora_app/features/wellness/presentation/cubits/water_reminder_cubit.dart';

const _primary = Color(0xFF2F1193);
const _accent = Color(0xFF29B6F6);

class WaterReminderPage extends StatelessWidget {
  const WaterReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WaterReminderCubit>()..load(),
      child: const _WaterReminderView(),
    );
  }
}

class _WaterReminderView extends StatelessWidget {
  const _WaterReminderView();

  String _fmt(int hour) {
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h $period';
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
          'Water Reminder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocListener<WaterReminderCubit, WaterReminderState>(
        listenWhen: (prev, curr) =>
            !prev.permissionDenied && curr.permissionDenied,
        listener: (context, state) {
          AppSnackBar.show(
            context,
            'Notifications are blocked. Enable them in system settings to get reminders.',
            type: AppSnackBarType.error,
          );
        },
        child: BlocBuilder<WaterReminderCubit, WaterReminderState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            final cubit = context.read<WaterReminderCubit>();
            final settings = state.settings;
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _HeroCard(enabled: settings.enabled, slotCount: settings.slots.length),
                const SizedBox(height: 24),
                _EnableSwitch(
                  value: settings.enabled,
                  onChanged: cubit.setEnabled,
                ),
                const SizedBox(height: 24),
                Opacity(
                  opacity: settings.enabled ? 1 : 0.45,
                  child: IgnorePointer(
                    ignoring: !settings.enabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle('Remind me every'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (final h in WaterReminderSettings.intervalOptions)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: _ChoiceChip(
                                  label: h == 1 ? '1 hour' : '$h hours',
                                  selected: settings.intervalHours == h,
                                  onTap: () => cubit.setInterval(h),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const _SectionTitle('Active hours'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _HourStepper(
                                label: 'From',
                                value: settings.startHour,
                                display: _fmt(settings.startHour),
                                onChanged: (v) {
                                  if (v < settings.endHour) {
                                    cubit.setWindow(
                                      startHour: v,
                                      endHour: settings.endHour,
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _HourStepper(
                                label: 'To',
                                value: settings.endHour,
                                display: _fmt(settings.endHour),
                                onChanged: (v) {
                                  if (v > settings.startHour) {
                                    cubit.setWindow(
                                      startHour: settings.startHour,
                                      endHour: v,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "You'll get ${settings.slots.length} reminders a day.",
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
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

class _HeroCard extends StatelessWidget {
  final bool enabled;
  final int slotCount;

  const _HeroCard({required this.enabled, required this.slotCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.water_drop_rounded, color: Colors.white, size: 44),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enabled ? 'Reminders are on' : 'Reminders are off',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  enabled
                      ? 'Vivi will nudge you $slotCount times a day.'
                      : 'Turn on reminders to stay hydrated.',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EnableSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _EnableSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        activeColor: _accent,
        title: const Text(
          'Enable water reminders',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _primary : const Color(0xFFDDDDE5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _HourStepper extends StatelessWidget {
  final String label;
  final int value;
  final String display;
  final ValueChanged<int> onChanged;

  const _HourStepper({
    required this.label,
    required this.value,
    required this.display,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RoundIconButton(
                icon: Icons.remove,
                onTap: () => onChanged(value - 1),
              ),
              Text(
                display,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              _RoundIconButton(
                icon: Icons.add,
                onTap: () => onChanged(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: _primary),
      ),
    );
  }
}
