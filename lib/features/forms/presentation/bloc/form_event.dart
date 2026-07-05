import 'package:equatable/equatable.dart';

sealed class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object?> get props => [];
}

final class LoadForm extends FormEvent {
  final String serviceId;

  const LoadForm({required this.serviceId});

  @override
  List<Object?> get props => [serviceId];
}

final class UpdateAnswer extends FormEvent {
  final String questionId;
  final String value;

  const UpdateAnswer({required this.questionId, required this.value});

  @override
  List<Object?> get props => [questionId, value];
}

final class PickFile extends FormEvent {
  final String questionId;
  final String filePath;
  final String fileName;

  const PickFile({
    required this.questionId,
    required this.filePath,
    required this.fileName,
  });

  @override
  List<Object?> get props => [questionId, filePath, fileName];
}

final class RemoveFile extends FormEvent {
  final String questionId;

  const RemoveFile({required this.questionId});

  @override
  List<Object?> get props => [questionId];
}

final class SubmitFormAndBook extends FormEvent {
  final String serviceId;
  final String staffId;
  final String branchId;
  final DateTime reservationDate;
  final int durationMinutes;
  final String paymentMethod;

  const SubmitFormAndBook({
    required this.serviceId,
    required this.staffId,
    required this.branchId,
    required this.reservationDate,
    required this.durationMinutes,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [
        serviceId,
        staffId,
        branchId,
        reservationDate,
        durationMinutes,
        paymentMethod,
      ];
}
