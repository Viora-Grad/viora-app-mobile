import 'package:equatable/equatable.dart';

class AiAction extends Equatable {
  final String label;
  final String specialty;

  const AiAction({
    required this.label,
    required this.specialty,
  });

  @override
  List<Object?> get props => [label, specialty];
}
