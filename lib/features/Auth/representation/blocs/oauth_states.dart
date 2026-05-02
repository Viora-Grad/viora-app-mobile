import 'package:equatable/equatable.dart';

enum OAuthStatus { initial, loading, success, failure }

final class OAuthState extends Equatable {
  final OAuthStatus status;
  final String? message;
  final String? token;

  const OAuthState({
    this.status = OAuthStatus.initial,
    this.message,
    this.token,
  });

  bool get isLoading => status == OAuthStatus.loading;

  bool get hasError => message != null && message!.trim().isNotEmpty;

  OAuthState copyWith({
    OAuthStatus? status,
    String? message,
    String? token,
    bool clearMessage = false,
    bool clearToken = false,
  }) {
    return OAuthState(
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
      token: clearToken ? null : (token ?? this.token),
    );
  }

  @override
  List<Object?> get props => [status, message, token];
}
