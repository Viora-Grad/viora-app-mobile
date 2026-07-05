import 'package:equatable/equatable.dart';

sealed class SplashEvents extends Equatable {
  const SplashEvents();

  @override
  List<Object?> get props => [];
}

final class SplashStarted extends SplashEvents {
  const SplashStarted();
}

final class SplashLogoAnimationFinished extends SplashEvents {
  const SplashLogoAnimationFinished();
}

final class SplashWaveTransitionFinished extends SplashEvents {
  const SplashWaveTransitionFinished();
}

final class SplashFirstIntroFinished extends SplashEvents {
  const SplashFirstIntroFinished();
}

final class SplashSecondIntroFinished extends SplashEvents {
  const SplashSecondIntroFinished();
}

final class SplashThirdIntroFinished extends SplashEvents {
  const SplashThirdIntroFinished();
}

final class SplashResetFirstIntro extends SplashEvents {
  const SplashResetFirstIntro();
}

final class SplashResetSecondIntro extends SplashEvents {
  const SplashResetSecondIntro();
}
