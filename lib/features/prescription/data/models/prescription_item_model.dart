import 'package:viora_app/features/prescription/domain/entities/prescription_item.dart';

class PrescriptionItemModel {
  final String name;
  final String? note;
  final String dose;
  final int frequence;
  final int duration;

  const PrescriptionItemModel({
    required this.name,
    this.note,
    required this.dose,
    required this.frequence,
    required this.duration,
  });

  factory PrescriptionItemModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionItemModel(
      name: json['name'] as String? ?? '',
      note: json['note'] as String?,
      dose: json['dose'] as String? ?? '',
      frequence: json['frequence'] as int? ?? 0,
      duration: json['duration'] as int? ?? 0,
    );
  }

  PrescriptionItem toEntity() {
    return PrescriptionItem(
      name: name,
      note: note,
      dose: dose,
      frequence: frequence,
      duration: duration,
    );
  }
}
