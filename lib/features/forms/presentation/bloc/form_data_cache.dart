import 'package:viora_app/features/forms/presentation/bloc/form_state.dart';

class FormDataCache {
  static Map<String, String>? _answers;
  static Map<String, FileData>? _files;
  static String? _formId;

  static bool get hasData => _answers != null;

  static void store({
    required Map<String, String> answers,
    required Map<String, FileData> files,
    required String formId,
  }) {
    _answers = answers;
    _files = files;
    _formId = formId;
  }

  static ({Map<String, String> answers, Map<String, FileData> files})?
      consume(String formId) {
    if (_answers == null || _formId != formId) return null;
    final data = <String, String>{};
    for (final e in _answers!.entries) {
      data[e.key] = e.value;
    }
    final fileData = <String, FileData>{};
    for (final e in _files!.entries) {
      fileData[e.key] = e.value;
    }
    clear();
    return (answers: data, files: fileData);
  }

  static void clear() {
    _answers = null;
    _files = null;
    _formId = null;
  }
}
