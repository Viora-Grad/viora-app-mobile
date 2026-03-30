import 'package:bloc/bloc.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/Auth/domain/usecases/register_usecase.dart';
import 'register_events.dart';
import 'register_states.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUsecase registerUsecase;

  RegisterBloc({required this.registerUsecase}) : super(const RegisterState()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<RegisterReset>(_onRegisterReset);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
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
        profilePicturePath: event.profilePicturePath,
      ),
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
  }

  void _onRegisterReset(RegisterReset event, Emitter<RegisterState> emit) {
    emit(const RegisterState());
  }
}
