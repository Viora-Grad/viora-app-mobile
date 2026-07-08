import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/features/wellness/domain/bmi_result.dart';

const _primary = Color(0xFF2F1193);

class BmiCalculatorPage extends StatefulWidget {
  const BmiCalculatorPage({super.key});

  @override
  State<BmiCalculatorPage> createState() => _BmiCalculatorPageState();
}

class _BmiCalculatorPageState extends State<BmiCalculatorPage> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  Gender _gender = Gender.male;
  BmiResult? _result;
  String? _error;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _calculate() {
    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());

    if (weight == null || weight <= 0 || weight > 500) {
      setState(() {
        _error = 'Enter a valid weight in kg.';
        _result = null;
      });
      return;
    }
    if (height == null || height < 50 || height > 260) {
      setState(() {
        _error = 'Enter a valid height in cm.';
        _result = null;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _result = BmiResult.calculate(
        weightKg: weight,
        heightCm: height,
        gender: _gender,
      );
    });
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
          'Body Check',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Is your weight right for your height?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter your details and Vivi will check it for you.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _GenderSelector(
            gender: _gender,
            onChanged: (g) => setState(() => _gender = g),
          ),
          const SizedBox(height: 20),
          _NumberField(
            controller: _weightController,
            label: 'Weight',
            suffix: 'kg',
            icon: Icons.monitor_weight_outlined,
          ),
          const SizedBox(height: 16),
          _NumberField(
            controller: _heightController,
            label: 'Height',
            suffix: 'cm',
            icon: Icons.height,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Color(0xFFF44336)),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
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
                'Check my result',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 28),
            _ResultCard(result: _result!),
          ],
        ],
      ),
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final Gender gender;
  final ValueChanged<Gender> onChanged;

  const _GenderSelector({required this.gender, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GenderOption(
            label: 'Male',
            icon: Icons.male,
            selected: gender == Gender.male,
            onTap: () => onChanged(Gender.male),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _GenderOption(
            label: 'Female',
            icon: Icons.female,
            selected: gender == Gender.female,
            onTap: () => onChanged(Gender.female),
          ),
        ),
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? _primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _primary : const Color(0xFFDDDDE5),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? _primary : Colors.grey, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? _primary : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData icon;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _primary),
        suffixText: suffix,
        filled: true,
        fillColor: const Color(0xFFF5F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final BmiResult result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = Color(result.category.colorValue);
    final range =
        '${result.healthyMinKg.toStringAsFixed(1)} – ${result.healthyMaxKg.toStringAsFixed(1)} kg';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                result.bmi.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BMI', style: TextStyle(color: Colors.grey)),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      result.category.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _InfoRow(label: 'Healthy weight for you', value: range),
          const SizedBox(height: 8),
          if (result.percentFromHealthy != 0)
            _InfoRow(
              label: result.percentFromHealthy < 0
                  ? 'Below healthy range by'
                  : 'Above healthy range by',
              value: '${result.percentFromHealthy.abs().toStringAsFixed(0)}%',
            ),
          const SizedBox(height: 16),
          Text(
            result.verdict,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
