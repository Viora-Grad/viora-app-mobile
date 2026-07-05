import 'package:equatable/equatable.dart';

class PrescriptionItem extends Equatable {
  final String name;
  final String? note;
  final String dose;
  final int frequence;
  final int duration;

  const PrescriptionItem({
    required this.name,
    this.note,
    required this.dose,
    required this.frequence,
    required this.duration,
  });

  @override
  List<Object?> get props => [name, note, dose, frequence, duration];
}
