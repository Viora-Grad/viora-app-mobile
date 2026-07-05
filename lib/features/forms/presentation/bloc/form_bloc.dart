import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/appointments/domain/usecases/book_appointment.dart';
import 'package:viora_app/features/forms/domain/entities/form_entity.dart';
import 'package:viora_app/features/forms/domain/usecases/get_service_form.dart';
import 'package:viora_app/features/forms/domain/usecases/submit_form_answer.dart';
import 'package:viora_app/features/forms/domain/usecases/upload_form_file.dart';
import 'package:viora_app/features/forms/presentation/bloc/form_event.dart';
import 'package:viora_app/features/forms/presentation/bloc/form_state.dart';

class FormBloc extends Bloc<FormEvent, FormLoadState> {
  final GetServiceFormUseCase getServiceForm;
  final BookAppointmentUseCase bookAppointment;
  final SubmitFormAnswerUseCase submitFormAnswer;
  final UploadFormFileUseCase uploadFormFile;

  FormBloc({
    required this.getServiceForm,
    required this.bookAppointment,
    required this.submitFormAnswer,
    required this.uploadFormFile,
  }) : super(const FormInitial()) {
    on<LoadForm>(_onLoadForm);
    on<UpdateAnswer>(_onUpdateAnswer);
    on<PickFile>(_onPickFile);
    on<RemoveFile>(_onRemoveFile);
    on<SubmitFormAndBook>(_onSubmitFormAndBook);
  }

  Future<void> _onLoadForm(LoadForm event, Emitter<FormLoadState> emit) async {
    emit(const FormLoading());

    final result = await getServiceForm(event.serviceId);

    result.fold(
      (failure) => emit(FormError(failure.message)),
      (form) {
        if (form == null) {
          emit(const FormError('Form not found'));
          return;
        }
        final answers = <String, String>{};
        for (final q in form.questions) {
          answers[q.id] = '';
        }
        emit(FormLoaded(form: form, answers: answers, files: {}));
      },
    );
  }

  void _onUpdateAnswer(UpdateAnswer event, Emitter<FormLoadState> emit) {
    final current = state;
    if (current is! FormLoaded) return;

    final updated = Map<String, String>.from(current.answers)
      ..[event.questionId] = event.value;
    final cleared = Map<String, String?>.from(current.errors)
      ..remove(event.questionId);
    emit(current.copyWith(
      answers: updated,
      errors: cleared.cast<String, String?>(),
    ));
  }

  void _onPickFile(PickFile event, Emitter<FormLoadState> emit) {
    final current = state;
    if (current is! FormLoaded) return;

    final updated = Map<String, FileData>.from(current.files)
      ..[event.questionId] = FileData(
        filePath: event.filePath,
        fileName: event.fileName,
      );
    emit(current.copyWith(files: updated));
  }

  void _onRemoveFile(RemoveFile event, Emitter<FormLoadState> emit) {
    final current = state;
    if (current is! FormLoaded) return;

    final updated = Map<String, FileData>.from(current.files)
      ..remove(event.questionId);
    emit(current.copyWith(files: updated));
  }

  Future<void> _onSubmitFormAndBook(
    SubmitFormAndBook event,
    Emitter<FormLoadState> emit,
  ) async {
    final current = state;
    if (current is! FormLoaded) return;

    final errors = <String, String?>{};
    for (final q in current.form.questions) {
      final answer = current.answers[q.id] ?? '';
      if (q.required &&
          answer.trim().isEmpty &&
          !current.files.containsKey(q.id)) {
        errors[q.id] = 'This field is required';
      }
    }

    if (errors.isNotEmpty) {
      emit(current.copyWith(errors: errors));
      return;
    }

    emit(const FormSubmitting());

    final bookResult = await bookAppointment(
      serviceId: event.serviceId,
      staffId: event.staffId,
      branchId: event.branchId,
      reservationDate: event.reservationDate,
      durationMinutes: event.durationMinutes,
      paymentMethod: event.paymentMethod,
    );

    final appointmentId = bookResult.fold(
      (failure) {
        emit(FormError(failure.message));
        return null;
      },
      (id) => id,
    );
    if (appointmentId == null) return;

    final answers = <AnswerData>[];
    for (final q in current.form.questions) {
      if (q.type == 'file') {
        final file = current.files[q.id];
        answers.add(AnswerData(
          id: q.id,
          type: q.type,
          answer: file?.fileName ?? '',
        ));
      } else {
        answers.add(AnswerData(
          id: q.id,
          type: q.type,
          answer: current.answers[q.id]?.trim() ?? '',
        ));
      }
    }

    final submitResult = await submitFormAnswer(
      appointmentId: appointmentId,
      formId: current.form.id,
      answers: answers,
    );

    final formSubmissionId = submitResult.fold(
      (failure) {
        emit(FormError(failure.message));
        return null;
      },
      (id) => id,
    );
    if (formSubmissionId == null) return;

    for (final entry in current.files.entries) {
      final uploadResult = await uploadFormFile(
        formSubmissionId: formSubmissionId,
        filePath: entry.value.filePath,
        fileName: entry.value.fileName,
      );

      final hasError = uploadResult.fold(
        (failure) {
          emit(FormError('File upload failed: ${failure.message}'));
          return true;
        },
        (_) => false,
      );
      if (hasError) return;
    }

    emit(FormSubmissionSuccess(appointmentId: appointmentId));
  }
}
