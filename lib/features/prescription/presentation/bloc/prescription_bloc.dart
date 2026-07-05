import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/prescription/domain/usecases/get_prescription_by_appointment.dart';
import 'package:viora_app/features/prescription/presentation/bloc/prescription_event.dart';
import 'package:viora_app/features/prescription/presentation/bloc/prescription_state.dart';

class PrescriptionBloc extends Bloc<PrescriptionEvent, PrescriptionState> {
  final GetPrescriptionByAppointment getPrescriptionByAppointment;

  PrescriptionBloc({required this.getPrescriptionByAppointment})
      : super(PrescriptionInitial()) {
    on<LoadPrescription>(_onLoadPrescription);
  }

  Future<void> _onLoadPrescription(
    LoadPrescription event,
    Emitter<PrescriptionState> emit,
  ) async {
    debugPrint('[PrescriptionBloc] Loading prescription for appointment: ${event.appointmentId}');
    emit(PrescriptionLoading());
    final result = await getPrescriptionByAppointment(event.appointmentId);
    result.fold(
      (failure) {
        debugPrint('[PrescriptionBloc] Error: ${failure.runtimeType} - ${failure.message}');
        emit(PrescriptionError(_mapFailureMessage(failure)));
      },
      (prescription) {
        debugPrint('[PrescriptionBloc] Loaded: ${prescription.id} with ${prescription.items.length} items');
        emit(PrescriptionLoaded(prescription));
      },
    );
  }

  String _mapFailureMessage(Failure failure) {
    if (failure is ServerFailure && failure.statusCode == 404) {
      return 'No prescription found for this appointment.';
    }
    return failure.message;
  }
}
