import 'package:equatable/equatable.dart';
import 'package:viora_app/features/forms/domain/entities/form_entity.dart';

sealed class FormLoadState extends Equatable {
  const FormLoadState();

  @override
  List<Object?> get props => [];
}

final class FormInitial extends FormLoadState {
  const FormInitial();
}

final class FormLoading extends FormLoadState {
  const FormLoading();
}

final class FormLoaded extends FormLoadState {
  final FormEntity form;
  final Map<String, String> answers;
  final Map<String, FileData> files;
  final Map<String, String?> errors;

  const FormLoaded({
    required this.form,
    required this.answers,
    required this.files,
    this.errors = const {},
  });

  FormLoaded copyWith({
    FormEntity? form,
    Map<String, String>? answers,
    Map<String, FileData>? files,
    Map<String, String?>? errors,
  }) {
    return FormLoaded(
      form: form ?? this.form,
      answers: answers ?? this.answers,
      files: files ?? this.files,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [form, answers, files, errors];
}

final class FormSubmitting extends FormLoadState {
  const FormSubmitting();
}

final class FormSubmissionSuccess extends FormLoadState {
  final String appointmentId;

  const FormSubmissionSuccess({required this.appointmentId});

  @override
  List<Object?> get props => [appointmentId];
}

final class FormError extends FormLoadState {
  final String message;

  const FormError(this.message);

  @override
  List<Object?> get props => [message];
}

class FileData extends Equatable {
  final String filePath;
  final String fileName;

  const FileData({required this.filePath, required this.fileName});

  @override
  List<Object?> get props => [filePath, fileName];
}
