import 'package:flutter/material.dart';
import 'package:viora_app/features/splash/representation/widgets/logo_widget.dart';
import 'package:viora_app/features/splash/representation/widgets/intro/third_intro_widget.dart';
import 'package:viora_app/features/splash/representation/widgets/wave_widget.dart';
import 'package:viora_app/features/splash/representation/widgets/intro/first_intro_widget.dart';
import 'package:viora_app/features/splash/representation/widgets/intro/second_intro_widget.dart';
import '../blocs/splash_phases.dart';

Widget buildContentForPhase(SplashPhase phase) {
  switch (phase) {
    case SplashPhase.initial:
      return const Center(child: CircularProgressIndicator());
    case SplashPhase.logoAnimation:
      return const LogoWidget();
    case SplashPhase.waveTransition:
      return const WaveWidget();
    case SplashPhase.firstIntro:
      return const FirstIntroWidget();
    case SplashPhase.secondIntro:
      return const SecondIntroWidget();
    case SplashPhase.thirdIntro:
      return const ThirdIntroWidget();
    case SplashPhase.resetFirstIntro:
      return const FirstIntroWidget();
    case SplashPhase.resetSecondIntro:
      return const SecondIntroWidget();
  }
}
