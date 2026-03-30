import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_bloc.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_events.dart';
import 'package:viora_app/features/splash/representation/widgets/intro/intro_step_widget.dart';
import 'package:viora_app/core/routes/app_router.dart';

/* 
  This widget represents the third introduction screen in the splash flow. It uses the IntroStepWidget to display an animation and a message, along with back and continue buttons. The back button allows the user to return to the second introduction screen, while the continue button signals that the third introduction is finished.
*/
class ThirdIntroWidget extends StatelessWidget {
  const ThirdIntroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroStepWidget(
      currentStep: 3,
      assetPath: 'assets/json/third_intro.json',
      message: 'Find trusted providers,\nSchedule it, Reserve instantly.',
      maxTextWidth: 500,
      continueIcon: Icons.check,
      onBack: () {
        context.read<SplashBloc>().add(const SplashResetSecondIntro());
      },
      onContinue: () {
        context.push(AppRoutes.register); 
      },
    );
  }
}
