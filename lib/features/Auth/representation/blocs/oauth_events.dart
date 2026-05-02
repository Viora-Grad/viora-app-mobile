import 'package:equatable/equatable.dart';
import 'package:viora_app/features/auth/domain/entities/oauth_provider_service.dart';

sealed class OAuthEvent extends Equatable {
  const OAuthEvent();

  @override
  List<Object?> get props => [];
}

final class OAuthGooglePressed extends OAuthEvent {
  const OAuthGooglePressed();

  @override
  List<Object?> get props => [OAuthProviderService.google];
}

final class OAuthReset extends OAuthEvent {
  const OAuthReset();
}
