import 'package:equatable/equatable.dart';
import 'package:viora_app/features/auth/domain/entities/user.dart';

enum LoginStatus { initial, loading, success, failure }

final class LoginState extends Equatable {
  final LoginStatus status;
  final String? errorMessage;
  final User? user;

  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.user,
  });

  bool get isLoading => status == LoginStatus.loading;

  bool get hasErrors => errorMessage != null && errorMessage!.trim().isNotEmpty;

  List<String> get errorMessages =>
      hasErrors ? [errorMessage!.trim()] : const [];

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    User? user,
    bool clearErrorMessage = false,
  }) {
    return LoginState(
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
