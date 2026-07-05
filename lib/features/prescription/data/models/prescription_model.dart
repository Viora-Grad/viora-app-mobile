import 'package:viora_app/features/prescription/data/models/prescription_item_model.dart';
import 'package:viora_app/features/prescription/domain/entities/prescription.dart';

class PrescriptionModel {
  final String id;
  final String appointmentId;
  final DateTime createdAt;
  final List<PrescriptionItemModel> items;

  const PrescriptionModel({
    required this.id,
    required this.appointmentId,
    required this.createdAt,
    required this.items,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List? ?? [])
        .map((e) =>
            PrescriptionItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return PrescriptionModel(
      id: json['id'] as String? ?? '',
      appointmentId: json['appointmentId'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createAt'] as String? ?? '') ??
          DateTime.now(),
      items: itemsList,
    );
  }

  Prescription toEntity() {
    return Prescription(
      id: id,
      appointmentId: appointmentId,
      createdAt: createdAt,
      items: items.map((m) => m.toEntity()).toList(),
    );
  }
}
