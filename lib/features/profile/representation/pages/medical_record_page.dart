import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/features/profile/domain/entities/medical_record.dart';
import 'package:viora_app/features/profile/representation/blocs/medical_record/medical_record_bloc.dart';
import 'package:viora_app/features/profile/representation/blocs/medical_record/medical_record_event.dart';
import 'package:viora_app/features/profile/representation/blocs/medical_record/medical_record_state.dart';

const Color _primary = Color(0xFF2F1193);

class MedicalRecordPage extends StatelessWidget {
  final MedicalRecord? existingRecord;

  const MedicalRecordPage({super.key, this.existingRecord});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<MedicalRecordBloc>(),
      child: _MedicalRecordView(existingRecord: existingRecord),
    );
  }
}

class _MedicalRecordView extends StatefulWidget {
  final MedicalRecord? existingRecord;

  const _MedicalRecordView({this.existingRecord});

  @override
  State<_MedicalRecordView> createState() => _MedicalRecordViewState();
}

class _MedicalRecordViewState extends State<_MedicalRecordView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _systolicCtrl;
  late final TextEditingController _diastolicCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _heartRateCtrl;
  late final TextEditingController _bloodGlucoseCtrl;
  final _allergyCtrl = TextEditingController();
  final _allergies = <String>[];
  bool _isEdit = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final r = widget.existingRecord;
    _isEdit = r != null;
    _systolicCtrl = TextEditingController(text: r?.systolic.toString() ?? '');
    _diastolicCtrl = TextEditingController(text: r?.diastolic.toString() ?? '');
    _weightCtrl = TextEditingController(text: r?.weight.toString() ?? '');
    _heartRateCtrl = TextEditingController(text: r?.heartRate.toString() ?? '');
    _bloodGlucoseCtrl = TextEditingController(text: r?.bloodGlucose.toString() ?? '');
    if (r != null) _allergies.addAll(r.allergies);

    if (r == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MedicalRecordBloc>().add(LoadMedicalRecord());
      });
    }
  }

  @override
  void dispose() {
    _systolicCtrl.dispose();
    _diastolicCtrl.dispose();
    _weightCtrl.dispose();
    _heartRateCtrl.dispose();
    _bloodGlucoseCtrl.dispose();
    _allergyCtrl.dispose();
    super.dispose();
  }

  void _addAllergy() {
    final text = _allergyCtrl.text.trim();
    if (text.isNotEmpty && !_allergies.contains(text)) {
      setState(() => _allergies.add(text));
      _allergyCtrl.clear();
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final systolic = int.parse(_systolicCtrl.text);
    final diastolic = int.parse(_diastolicCtrl.text);
    final weight = double.parse(_weightCtrl.text);
    final heartRate = int.parse(_heartRateCtrl.text);
    final bloodGlucose = int.parse(_bloodGlucoseCtrl.text);

    if (_isEdit) {
      context.read<MedicalRecordBloc>().add(UpdateMedicalRecordEvent(
        systolic: systolic,
        diastolic: diastolic,
        weight: weight,
        heartRate: heartRate,
        bloodGlucose: bloodGlucose,
        allergies: _allergies,
      ));
    } else {
      context.read<MedicalRecordBloc>().add(CreateMedicalRecordEvent(
        systolic: systolic,
        diastolic: diastolic,
        weight: weight,
        heartRate: heartRate,
        bloodGlucose: bloodGlucose,
        allergies: _allergies,
      ));
    }
  }

  void _populateFromRecord(MedicalRecord r) {
    if (!mounted) return;
    setState(() {
      _isEdit = true;
      _isLoading = false;
      _systolicCtrl.text = r.systolic.toString();
      _diastolicCtrl.text = r.diastolic.toString();
      _weightCtrl.text = r.weight.toString();
      _heartRateCtrl.text = r.heartRate.toString();
      _bloodGlucoseCtrl.text = r.bloodGlucose.toString();
      _allergies
        ..clear()
        ..addAll(r.allergies);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEdit ? 'Edit Medical Record' : 'Create Medical Record',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocConsumer<MedicalRecordBloc, MedicalRecordState>(
        listener: (context, state) {
          if (state.status == MedicalRecordStatus.success && state.record != null) {
            _populateFromRecord(state.record!);
          }
          if (state.status == MedicalRecordStatus.failure && state.error != null) {
            if (_isLoading) setState(() => _isLoading = false);
          }
          if (state.status == MedicalRecordStatus.saved) {
            final message = _isEdit
                ? 'Medical record is updated successfully'
                : 'Medical record is created successfully';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: const Color(0xFF28F0A8),
              ),
            );
            Future.delayed(const Duration(milliseconds: 600), () {
              if (context.mounted) context.pop(message);
            });
          }
        },
        builder: (context, state) {
          if (state.status == MedicalRecordStatus.loading && !_isEdit) {
            _isLoading = true;
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(text: 'Blood Pressure'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildField('Systolic', _systolicCtrl, 'mmHg', 1, 300)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField('Diastolic', _diastolicCtrl, 'mmHg', 1, 200)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(text: 'Vitals'),
                  const SizedBox(height: 12),
                  _buildField('Weight (kg)', _weightCtrl, 'kg', 1, 300, isDouble: true),
                  const SizedBox(height: 16),
                  _buildField('Heart Rate', _heartRateCtrl, 'bpm', 1, 200),
                  const SizedBox(height: 16),
                  _buildField('Blood Glucose', _bloodGlucoseCtrl, 'mg/dL', 1, 250),
                  const SizedBox(height: 24),
                  _SectionTitle(text: 'Allergies'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _allergyCtrl,
                          decoration: InputDecoration(
                            hintText: 'Add allergy...',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addAllergy,
                        icon: const Icon(Icons.add_circle, color: _primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allergies
                        .map((a) => Chip(
                              label: Text(a, style: const TextStyle(fontSize: 13)),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => setState(() => _allergies.remove(a)),
                              backgroundColor: _primary.withValues(alpha: 0.08),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: state.status == MedicalRecordStatus.loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              _isEdit ? 'Save Changes' : 'Create Record',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    String suffix,
    int min,
    int max, {
    bool isDouble = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.numberWithOptions(decimal: isDouble),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        suffixStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: const Color(0xFFF5F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Required';
        final num? parsed = isDouble ? double.tryParse(v) : int.tryParse(v);
        if (parsed == null) return 'Invalid number';
        if (parsed < min || parsed > max) return '$min-$max';
        return null;
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }
}
