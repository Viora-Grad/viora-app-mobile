import 'package:bloc/bloc.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/auth/domain/usecases/register_usecase.dart';
import 'register_events.dart';
import 'register_states.dart';
import 'package:dio/dio.dart';

// Brief: This is the RegisterBloc, which manages the state of the registration
// process in the presentation layer. It listens for RegisterSubmitted events,
// calls the RegisterUsecase to perform the registration logic,
// and emits RegisterState updates based on the success or failure of the
// registration attempt. It also handles cancellation of ongoing registration
// requests when a new one is initiated or when the bloc is closed.


class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUsecase registerUsecase;
  CancelToken? _cancelToken; // Track active registration request
  bool _isRegistering = false;

  RegisterBloc({required this.registerUsecase}) : super(const RegisterState()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<RegisterReset>(_onRegisterReset);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    if (_isRegistering) {
      return;
    }

    _isRegistering = true;
    _cancelToken = CancelToken();

    try {
      emit(
        state.copyWith(status: RegisterStatus.loading, clearErrorMessage: true),
      );

      final result = await registerUsecase(
        RegisterParameters(
          userName: event.userName,
          email: event.email,
          password: event.password,
          phoneNumber: event.phoneNumber,
          gender: event.gender,
          age: event.age,
        ),
        cancelToken: _cancelToken,
      );

      result.fold(
        (failure) => emit(
          state.copyWith(
            status: RegisterStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (user) => emit(
          state.copyWith(
            status: RegisterStatus.success,
            clearErrorMessage: true,
            user: user,
          ),
        ),
      );
    } finally {
      _isRegistering = false;
      _cancelToken = null;
    }
  }

  void _onRegisterReset(RegisterReset event, Emitter<RegisterState> emit) {
    emit(const RegisterState());
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel(); // Cancel any active request when bloc is closed
    return super.close();
  }
}
