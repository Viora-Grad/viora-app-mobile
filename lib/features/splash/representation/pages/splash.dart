import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/splash_bloc.dart';
import '../widgets/splash_widget.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_states.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SplashBloc, SplashState>(
      builder: (context, state) {
        return buildContentForPhase(state.phase);
      },
    );
  }
}
