import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/features/profile/domain/entities/medical_record.dart';
import 'package:viora_app/features/profile/representation/blocs/medical_record/medical_record_bloc.dart';
import 'package:viora_app/features/profile/representation/blocs/medical_record/medical_record_event.dart';
import 'package:viora_app/features/profile/representation/blocs/medical_record/medical_record_state.dart';

const Color _primary = Color(0xFF2F1193);

class MedicalRecordBanner extends StatefulWidget {
  const MedicalRecordBanner({super.key});

  @override
  State<MedicalRecordBanner> createState() => _MedicalRecordBannerState();
}

class _MedicalRecordBannerState extends State<MedicalRecordBanner> {
  @override
  void initState() {
    super.initState();
    sl<MedicalRecordBloc>().add(LoadMedicalRecord());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<MedicalRecordBloc>(),
      child: BlocBuilder<MedicalRecordBloc, MedicalRecordState>(
        builder: (context, state) {
          if (state.status == MedicalRecordStatus.loading ||
              state.status == MedicalRecordStatus.initial) {
            return const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.record != null) {
            return _MedicalRecordCards(record: state.record!);
          }

          return _CreateRecordBanner();
        },
      ),
    );
  }
}

class _CreateRecordBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openForm(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A0A6E), Color(0xFF4A1A8A), Color(0xFF6B3FA0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Medical Record',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your vitals and allergies',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _openForm(BuildContext context) async {
    final message = await context.push<String>('/medical-record');
    if (message != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF28F0A8),
        ),
      );
    }
  }
}

class _MedicalRecordCards extends StatelessWidget {
  final MedicalRecord record;

  const _MedicalRecordCards({required this.record});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medical Record',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _VitalCard(icon: Icons.monitor_heart_outlined, label: 'BP', value: '${record.systolic}/${record.diastolic}', unit: 'mmHg')),
            const SizedBox(width: 10),
            Expanded(child: _VitalCard(icon: Icons.monitor_weight_outlined, label: 'Weight', value: record.weight.toStringAsFixed(1), unit: 'kg')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _VitalCard(icon: Icons.favorite_border, label: 'Heart Rate', value: '${record.heartRate}', unit: 'bpm')),
            const SizedBox(width: 10),
            Expanded(child: _VitalCard(icon: Icons.bloodtype_outlined, label: 'Glucose', value: '${record.bloodGlucose}', unit: 'mg/dL')),
          ],
        ),
        if (record.allergies.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: record.allergies
                .map((a) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(a, style: const TextStyle(fontSize: 11, color: Color(0xFFE65100))),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _VitalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  const _VitalCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: _primary),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
