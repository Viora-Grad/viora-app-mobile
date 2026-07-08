import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/Auth/data/datasources/remote/auth_remote.dart';
import 'package:viora_app/core/errors/exceptions.dart';

enum ForgotPasswordStep { email, otp }
enum ForgotPasswordStatus { initial, loading, success, failure }

class ForgotPasswordState {
  final ForgotPasswordStep step;
  final ForgotPasswordStatus status;
  final String? error;
  final String email;

  const ForgotPasswordState({
    this.step = ForgotPasswordStep.email,
    this.status = ForgotPasswordStatus.initial,
    this.error,
    this.email = '',
  });

  ForgotPasswordState copyWith({
    ForgotPasswordStep? step,
    ForgotPasswordStatus? status,
    String? error,
    String? email,
  }) {
    return ForgotPasswordState(
      step: step ?? this.step,
      status: status ?? this.status,
      error: error,
      email: email ?? this.email,
    );
  }
}

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthRemoteDataSource _authRemote;

  ForgotPasswordCubit(this._authRemote) : super(const ForgotPasswordState());

  Future<void> sendOtp(String email) async {
    emit(state.copyWith(status: ForgotPasswordStatus.loading));
    try {
      await _authRemote.forgetPassword(email);
      emit(state.copyWith(
        step: ForgotPasswordStep.otp,
        status: ForgotPasswordStatus.initial,
        email: email,
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        error: e.errorModel.errorMessage,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> confirmReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    emit(state.copyWith(status: ForgotPasswordStatus.loading));
    try {
      await _authRemote.confirmForgetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      emit(state.copyWith(status: ForgotPasswordStatus.success));
    } on ServerException catch (e) {
      emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        error: e.errorModel.errorMessage,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        error: e.toString(),
      ));
    }
  }

  void resetError() {
    emit(state.copyWith(status: ForgotPasswordStatus.initial, error: null));
  }
}
