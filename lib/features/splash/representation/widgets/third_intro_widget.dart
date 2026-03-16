import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_bloc.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_events.dart';
import 'package:viora_app/features/splash/representation/widgets/intro_step_widget.dart';

class ThirdIntroWidget extends StatelessWidget {
  const ThirdIntroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroStepWidget(
      assetPath: 'assets/json/third_intro.json',
      message: 'Find trusted providers,\nSchedule it, Reserve instantly.',
      maxTextWidth: 500,
      continueIcon: Icons.check,
      onBack: () {
        context.read<SplashBloc>().add(const SplashResetSecondIntro());
      },
      onContinue: () {
        context.read<SplashBloc>().add(const SplashThirdIntroFinished());
      },
    );
  }
}
