import 'package:equatable/equatable.dart';
import 'package:viora_app/features/Auth/domain/entities/user.dart';

enum OAuthStatus { initial, loading, success, failure, needsRegistration }

final class OAuthState extends Equatable {
  final OAuthStatus status;
  final String? message;
  final User? user;

  final String? registrationProviderKey;
  final String? registrationEmail;
  final String? registrationFirstName;
  final String? registrationLastName;

  const OAuthState({
    this.status = OAuthStatus.initial,
    this.message,
    this.user,
    this.registrationProviderKey,
    this.registrationEmail,
    this.registrationFirstName,
    this.registrationLastName,
  });

  bool get isLoading => status == OAuthStatus.loading;

  bool get hasError => message != null && message!.trim().isNotEmpty;

  OAuthState copyWith({
    OAuthStatus? status,
    String? message,
    User? user,
    String? registrationProviderKey,
    String? registrationEmail,
    String? registrationFirstName,
    String? registrationLastName,
    bool clearMessage = false,
    bool clearUser = false,
    bool clearRegistration = false,
  }) {
    return OAuthState(
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
      user: clearUser ? null : (user ?? this.user),
      registrationProviderKey: clearRegistration
          ? null
          : (registrationProviderKey ?? this.registrationProviderKey),
      registrationEmail:
          clearRegistration ? null : (registrationEmail ?? this.registrationEmail),
      registrationFirstName: clearRegistration
          ? null
          : (registrationFirstName ?? this.registrationFirstName),
      registrationLastName: clearRegistration
          ? null
          : (registrationLastName ?? this.registrationLastName),
    );
  }

  @override
  List<Object?> get props => [
    status,
    message,
    user,
    registrationProviderKey,
    registrationEmail,
    registrationFirstName,
    registrationLastName,
  ];
}
