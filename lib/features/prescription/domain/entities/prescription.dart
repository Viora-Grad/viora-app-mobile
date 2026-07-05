import 'package:equatable/equatable.dart';
import 'package:viora_app/features/prescription/domain/entities/prescription_item.dart';

class Prescription extends Equatable {
  final String id;
  final String appointmentId;
  final DateTime createdAt;
  final List<PrescriptionItem> items;

  const Prescription({
    required this.id,
    required this.appointmentId,
    required this.createdAt,
    required this.items,
  });

  @override
  List<Object?> get props => [id, appointmentId, createdAt, items];
}
