import 'package:bloc/bloc.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/auth/domain/entities/oauth_provider_service.dart';
import 'package:viora_app/features/auth/domain/usecases/sign_in_with_oauth_usecase.dart';

import 'oauth_events.dart';
import 'oauth_states.dart';

class OAuthBloc extends Bloc<OAuthEvent, OAuthState> {
  final SignInWithOAuthUseCase signInWithOAuthUseCase;

  OAuthBloc({required this.signInWithOAuthUseCase})
    : super(const OAuthState()) {
    on<OAuthGooglePressed>(_onGooglePressed);
    on<OAuthReset>(_onReset);
  }

  Future<void> _onGooglePressed(
    OAuthGooglePressed event,
    Emitter<OAuthState> emit,
  ) async {
    emit(state.copyWith(status: OAuthStatus.loading, clearMessage: true));

    final result = await signInWithOAuthUseCase(OAuthProviderService.google);

    result.fold(
      (failure) {
        if (failure is OAuthCancelledFailure) {
          emit(
            state.copyWith(
              status: OAuthStatus.initial,
              clearMessage: true,
              clearToken: true,
            ),
          );
          return;
        }

        emit(
          state.copyWith(status: OAuthStatus.failure, message: failure.message),
        );
      },
      (token) => emit(
        state.copyWith(
          status: OAuthStatus.success,
          clearMessage: true,
          token: token,
        ),
      ),
    );
  }

  void _onReset(OAuthReset event, Emitter<OAuthState> emit) {
    emit(const OAuthState());
  }
}
