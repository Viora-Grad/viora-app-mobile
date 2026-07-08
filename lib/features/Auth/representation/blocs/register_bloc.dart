import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/Auth/domain/usecases/register_usecase.dart';
import 'register_events.dart';
import 'register_states.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUsecase registerUsecase;
  CancelToken? _cancelToken;
  bool _isRegistering = false;

  RegisterBloc({required this.registerUsecase}) : super(const RegisterState()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<OAuthRegisterSubmitted>(_onOAuthRegisterSubmitted);
    on<RegisterReset>(_onRegisterReset);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    if (_isRegistering) return;

    _isRegistering = true;
    _cancelToken = CancelToken();

    try {
      emit(
        state.copyWith(status: RegisterStatus.loading, clearErrorMessage: true),
      );

      final result = await registerUsecase(
        RegisterParameters(
          firstName: event.firstName,
          lastName: event.lastName,
          email: event.email,
          password: event.password,
          gender: event.gender,
          dateOfBirth: event.dateOfBirth,
          userName: event.userName,
          phoneNumber: event.phoneNumber,
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

  Future<void> _onOAuthRegisterSubmitted(
    OAuthRegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    if (_isRegistering) return;

    _isRegistering = true;
    _cancelToken = CancelToken();

    try {
      emit(
        state.copyWith(status: RegisterStatus.loading, clearErrorMessage: true),
      );

      final result = await registerUsecase.oauthRegister(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        gender: event.gender,
        dateOfBirth: event.dateOfBirth,
        providerKey: event.providerKey,
        userName: event.userName,
        phoneNumber: event.phoneNumber,
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
    _cancelToken?.cancel();
    return super.close();
  }
}
