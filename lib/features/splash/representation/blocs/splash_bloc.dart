import 'package:bloc/bloc.dart';
import 'splash_events.dart';
import 'splash_states.dart';
import 'splash_phases.dart';

class SplashBloc extends Bloc<SplashEvents, SplashState> {
  SplashBloc() : super(const SplashState(SplashPhase.initial)) {
    on<SplashStarted>(_onSplashStarted);
    on<SplashLogoAnimationFinished>(_onLogoAnimationFinished);
    on<SplashWaveTransitionFinished>(_onWaveTransitionFinished);
    on<SplashFirstIntroFinished>(_onFirstIntroFinished);
    on<SplashSecondIntroFinished>(_onSecondIntroFinished);
    on<SplashThirdIntroFinished>(_onThirdIntroFinished);
    on<SplashResetFirstIntro>(_onResetFirstIntro);
    on<SplashResetSecondIntro>(_onResetSecondIntro);
  }

  void _onSplashStarted(SplashStarted event, Emitter<SplashState> emit) {
    emit(const SplashState(SplashPhase.logoAnimation));
  }

  void _onLogoAnimationFinished(
    SplashLogoAnimationFinished event,
    Emitter<SplashState> emit,
  ) {
    emit(const SplashState(SplashPhase.waveTransition));
  }

  void _onWaveTransitionFinished(
    SplashWaveTransitionFinished event,
    Emitter<SplashState> emit,
  ) {
    emit(const SplashState(SplashPhase.firstIntro));
  }

  void _onFirstIntroFinished(
    SplashFirstIntroFinished event,
    Emitter<SplashState> emit,
  ) {
    emit(const SplashState(SplashPhase.secondIntro));
  }

  void _onSecondIntroFinished(
    SplashSecondIntroFinished event,
    Emitter<SplashState> emit,
  ) {
    emit(const SplashState(SplashPhase.thirdIntro));
  }

  void _onThirdIntroFinished(
    SplashThirdIntroFinished event,
    Emitter<SplashState> emit,
  ) {
    emit(const SplashState(SplashPhase.initial));
  }

  void _onResetFirstIntro(
    SplashResetFirstIntro event,
    Emitter<SplashState> emit,
  ) {
    emit(const SplashState(SplashPhase.resetFirstIntro));
  }

  void _onResetSecondIntro(
    SplashResetSecondIntro event,
    Emitter<SplashState> emit,
  ) {
    emit(const SplashState(SplashPhase.resetSecondIntro));
  }
}
