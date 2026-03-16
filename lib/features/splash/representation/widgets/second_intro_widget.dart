import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_bloc.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_events.dart';
import 'package:viora_app/features/splash/representation/widgets/intro_step_widget.dart';

class SecondIntroWidget extends StatelessWidget {
  const SecondIntroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroStepWidget(
      assetPath: 'assets/json/second_intro.json',
      message: 'Manage your appointments effortlessly, all in one place.',
      onBack: () {
        context.read<SplashBloc>().add(const SplashResetFirstIntro());
      },
      onContinue: () {
        context.read<SplashBloc>().add(const SplashSecondIntroFinished());
      },
    );
  }
}
