import 'package:equatable/equatable.dart';
import 'package:viora_app/features/forms/data/models/form_model.dart';

class FormFieldEntity extends Equatable {
  final String id;
  final String type;
  final String label;
  final bool required;
  final String? placeholder;
  final List<String>? options;
  final List<String>? accept;

  const FormFieldEntity({
    required this.id,
    required this.type,
    required this.label,
    this.required = false,
    this.placeholder,
    this.options,
    this.accept,
  });

  @override
  List<Object?> get props =>
      [id, type, label, required, placeholder, options, accept];
}

class FormEntity extends Equatable {
  final String id;
  final String staffId;
  final String serviceId;
  final String name;
  final List<FormFieldEntity> questions;

  const FormEntity({
    required this.id,
    required this.staffId,
    required this.serviceId,
    required this.name,
    required this.questions,
  });

  @override
  List<Object?> get props => [id, staffId, serviceId, name, questions];
}

class AnswerData extends Equatable {
  final String id;
  final String type;
  final String answer;

  const AnswerData({
    required this.id,
    required this.type,
    required this.answer,
  });

  @override
  List<Object?> get props => [id, type, answer];
}

extension FormModelX on FormModel {
  FormEntity toEntity() {
    return FormEntity(
      id: id,
      staffId: staffId,
      serviceId: serviceId,
      name: name,
      questions: questions
          .map((q) => FormFieldEntity(
                id: q.id,
                type: q.type,
                label: q.label,
                required: q.required,
                placeholder: q.placeholder,
                options: q.options,
                accept: q.accept,
              ))
          .toList(),
    );
  }
}
