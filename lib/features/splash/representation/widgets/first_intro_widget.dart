import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_bloc.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_events.dart';
import 'package:viora_app/features/splash/representation/widgets/intro_step_widget.dart';

class FirstIntroWidget extends StatelessWidget {
  const FirstIntroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroStepWidget(
      assetPath: 'assets/json/first_intro.json',
      message: 'Discover wellness and healthcare appointments in seconds.',
      onContinue: () {
        context.read<SplashBloc>().add(const SplashFirstIntroFinished());
      },
    );
  }
}
