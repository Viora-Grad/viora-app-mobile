import 'package:equatable/equatable.dart';
import 'package:viora_app/features/auth/domain/entities/user.dart';

// Brief: This file defines the states for the RegisterBloc, which represent the
// different stages of the registration process. The RegisterState class includes
// properties for the current status of the registration (initial, loading, success, failure),
// any error messages, and the registered user data. It also provides helper getters
// to determine if the registration is currently loading or if there are any errors.

enum RegisterStatus { initial, loading, success, failure }

final class RegisterState extends Equatable {
  final RegisterStatus status;
  final String? errorMessage;
  final User? user;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.errorMessage,
    this.user,
  });

  bool get isLoading => status == RegisterStatus.loading;

  bool get hasErrors => errorMessage != null && errorMessage!.trim().isNotEmpty;

  List<String> get errorMessages =>
      hasErrors ? [errorMessage!.trim()] : const [];

  RegisterState copyWith({
    RegisterStatus? status,
    String? errorMessage,
    User? user,
    bool clearErrorMessage = false,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, user];
}
