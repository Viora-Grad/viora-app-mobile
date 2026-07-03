import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/widgets/app_snackbar.dart';
import 'package:viora_app/features/wellness/domain/sleep_advice.dart';
import 'package:viora_app/features/wellness/domain/sleep_entry.dart';
import 'package:viora_app/features/wellness/domain/sleep_suggestion.dart';
import 'package:viora_app/features/wellness/presentation/cubits/sleep_cubit.dart';

const _primary = Color(0xFF2F1193);
const _accent = Color(0xFF7E57C2);

class SleepTrackerPage extends StatelessWidget {
  const SleepTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SleepCubit>()..load(),
      child: const _SleepTrackerView(),
    );
  }
}

class _SleepTrackerView extends StatelessWidget {
  const _SleepTrackerView();

  String _fmtDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return '${h}h ${m}m';
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
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
          'Sleep Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton.extended(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          onPressed: () => _openAddSheet(context),
          icon: const Icon(Icons.add),
          label: const Text('Log sleep'),
        ),
      ),
      body: BlocBuilder<SleepCubit, SleepState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
            children: [
              if (state.suggestion != null) ...[
                _SuggestionCard(
                  suggestion: state.suggestion!,
                  onAccept: () {
                    context.read<SleepCubit>().acceptSuggestion();
                    AppSnackBar.show(
                      context,
                      'Sleep logged. Sweet dreams counted! 🌙',
                      type: AppSnackBarType.success,
                    );
                  },
                  onDismiss: () =>
                      context.read<SleepCubit>().dismissSuggestion(),
                ),
                const SizedBox(height: 24),
              ],
              _AdviceCard(advice: state.advice),
              const SizedBox(height: 24),
              const Text(
                'Recent nights',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (state.entries.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No sleep logged yet.\nTap "Log sleep" to add your first night.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...state.entries.map(
                  (e) => _SleepTile(
                    entry: e,
                    dateLabel: _fmtDate(e.bedtime),
                    durationLabel: _fmtDuration(e.duration),
                    onDelete: () =>
                        context.read<SleepCubit>().deleteEntry(e.id),
                  ),
                ),
              if (state.entries.length >= WellnessSleepLimit.max) ...[
                const SizedBox(height: 8),
                const Text(
                  'Showing your latest 30 nights.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _openAddSheet(BuildContext context) async {
    final cubit = context.read<SleepCubit>();
    final result = await showModalBottomSheet<_SleepInput>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _AddSleepSheet(),
    );
    if (result != null) {
      await cubit.addEntry(bedtime: result.bedtime, wakeTime: result.wakeTime);
    }
  }
}

class WellnessSleepLimit {
  static const int max = 30;
}

class _SuggestionCard extends StatelessWidget {
  final SleepSuggestion suggestion;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  const _SuggestionCard({
    required this.suggestion,
    required this.onAccept,
    required this.onDismiss,
  });

  String _clock(DateTime d) {
    final period = d.hour < 12 ? 'AM' : 'PM';
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final d = suggestion.duration;
    final durationLabel = '${d.inHours}h ${d.inMinutes % 60}m';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.nights_stay_rounded, color: _accent),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Did you just sleep?',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Your phone was idle for $durationLabel — from '
            '${_clock(suggestion.start)} to ${_clock(suggestion.end)}. '
            'Want to log this as sleep?',
            style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Yes, log it',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onDismiss,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: const BorderSide(color: Color(0xFFDDDDE5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'No, thanks',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  final SleepAdvice advice;

  const _AdviceCard({required this.advice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7E57C2), Color(0xFF5E35B1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bedtime_rounded, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              if (advice.quality != SleepQuality.none)
                Text(
                  '${advice.averageHours.toStringAsFixed(1)}h avg',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            advice.message,
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _SleepTile extends StatelessWidget {
  final SleepEntry entry;
  final String dateLabel;
  final String durationLabel;
  final VoidCallback onDelete;

  const _SleepTile({
    required this.entry,
    required this.dateLabel,
    required this.durationLabel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF44336),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E8EE)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.nightlight_round, color: _accent),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  durationLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_fmtTime(entry.bedtime)} → ${_fmtTime(entry.wakeTime)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            Text(
              dateLabel,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtTime(DateTime d) {
    final period = d.hour < 12 ? 'AM' : 'PM';
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }
}

/// Result payload from the add-sleep bottom sheet.
class _SleepInput {
  final DateTime bedtime;
  final DateTime wakeTime;

  const _SleepInput(this.bedtime, this.wakeTime);
}

class _AddSleepSheet extends StatefulWidget {
  const _AddSleepSheet();

  @override
  State<_AddSleepSheet> createState() => _AddSleepSheetState();
}

class _AddSleepSheetState extends State<_AddSleepSheet> {
  DateTime _wakeDate = DateTime.now();
  TimeOfDay _bedtime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);

  /// Duration preview, handling sessions that cross midnight.
  Duration get _preview {
    final bedMinutes = _bedtime.hour * 60 + _bedtime.minute;
    final wakeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    var diff = wakeMinutes - bedMinutes;
    if (diff <= 0) diff += 24 * 60;
    return Duration(minutes: diff);
  }

  void _save() {
    // Anchor wake time to the chosen date; if bedtime is later in the clock
    // than wake time, the user went to bed the previous calendar day.
    final wake = DateTime(
      _wakeDate.year,
      _wakeDate.month,
      _wakeDate.day,
      _wakeTime.hour,
      _wakeTime.minute,
    );
    var bed = DateTime(
      _wakeDate.year,
      _wakeDate.month,
      _wakeDate.day,
      _bedtime.hour,
      _bedtime.minute,
    );
    if (!bed.isBefore(wake)) {
      bed = bed.subtract(const Duration(days: 1));
    }
    Navigator.of(context).pop(_SleepInput(bed, wake));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _wakeDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
    );
    if (picked != null) setState(() => _wakeDate = picked);
  }

  Future<void> _pickBedtime() async {
    final picked = await showTimePicker(context: context, initialTime: _bedtime);
    if (picked != null) setState(() => _bedtime = picked);
  }

  Future<void> _pickWakeTime() async {
    final picked = await showTimePicker(context: context, initialTime: _wakeTime);
    if (picked != null) setState(() => _wakeTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final h = _preview.inHours;
    final m = _preview.inMinutes % 60;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDE5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Log your sleep',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _PickerRow(
            icon: Icons.calendar_today_outlined,
            label: 'Woke up on',
            value: '${_wakeDate.day}/${_wakeDate.month}/${_wakeDate.year}',
            onTap: _pickDate,
          ),
          const SizedBox(height: 12),
          _PickerRow(
            icon: Icons.bedtime_outlined,
            label: 'Went to bed',
            value: _bedtime.format(context),
            onTap: _pickBedtime,
          ),
          const SizedBox(height: 12),
          _PickerRow(
            icon: Icons.wb_sunny_outlined,
            label: 'Woke up',
            value: _wakeTime.format(context),
            onTap: _pickWakeTime,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'That\'s ${h}h ${m}m of sleep',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: _accent,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: _primary),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: _primary,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
