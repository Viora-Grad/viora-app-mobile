class FormFieldModel {
  final String id;
  final String type;
  final String label;
  final bool required;
  final String? placeholder;
  final List<String>? options;
  final List<String>? accept;

  const FormFieldModel({
    required this.id,
    required this.type,
    required this.label,
    this.required = false,
    this.placeholder,
    this.options,
    this.accept,
  });

  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) return value.cast<String>();
    if (value is String) {
      if (value.isEmpty) return null;
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return null;
  }

  factory FormFieldModel.fromJson(Map<String, dynamic> json) {
    return FormFieldModel(
      id: (json['id'] as String? ?? json['name'] as String?) ?? '',
      type: json['type'] as String? ?? 'text',
      label: json['label'] as String? ?? '',
      required: json['required'] as bool? ?? false,
      placeholder: json['placeholder'] as String?,
      options: _parseStringList(json['options']),
      accept: _parseStringList(json['accept']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'label': label,
        'required': required,
        if (placeholder != null) 'placeholder': placeholder,
        if (options != null) 'options': options,
        if (accept != null) 'accept': accept,
      };
}

class FormModel {
  final String id;
  final String staffId;
  final String serviceId;
  final String name;
  final List<FormFieldModel> questions;

  const FormModel({
    required this.id,
    required this.staffId,
    required this.serviceId,
    required this.name,
    required this.questions,
  });

  factory FormModel.fromJson(Map<String, dynamic> json) {
    List<FormFieldModel> questions = [];

    final rawQuestions = json['questions'];
    if (rawQuestions is List) {
      questions = rawQuestions
          .map((e) => FormFieldModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      final fields = json['fields'];
      if (fields is List) {
        questions = fields
            .map((e) => FormFieldModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (fields is Map<String, dynamic>) {
        for (final key in ['questions', 'fields', 'formFields', 'items']) {
          final value = fields[key];
          if (value is List) {
            questions = value
                .map((e) => FormFieldModel.fromJson(e as Map<String, dynamic>))
                .toList();
            break;
          }
        }
        if (questions.isEmpty) {
          for (final value in fields.values) {
            if (value is List && value.isNotEmpty && value.first is Map) {
              questions = value
                  .map((e) => FormFieldModel.fromJson(e as Map<String, dynamic>))
                  .toList();
              break;
            }
          }
        }
      }
    }

    return FormModel(
      id: json['id'] as String? ?? '',
      staffId: json['staffId'] as String? ?? '',
      serviceId: json['serviceId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      questions: questions,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'staffId': staffId,
        'serviceId': serviceId,
        'name': name,
        'fields': {
          'questions': questions.map((e) => e.toJson()).toList(),
        },
      };
}

class AnswerModel {
  final String id;
  final String type;
  final String answer;

  const AnswerModel({
    required this.id,
    required this.type,
    required this.answer,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'answer': answer,
      };
}

class FormSubmissionModel {
  final String id;
  final String appointmentId;
  final String formId;
  final DateTime createdAt;

  const FormSubmissionModel({
    required this.id,
    required this.appointmentId,
    required this.formId,
    required this.createdAt,
  });

  factory FormSubmissionModel.fromJson(Map<String, dynamic> json) {
    return FormSubmissionModel(
      id: json['id'] as String? ?? '',
      appointmentId: json['appointmentId'] as String? ?? '',
      formId: json['formId'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
