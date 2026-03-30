import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/features/Auth/representation/pages/register.dart';
import 'package:viora_app/features/Auth/representation/pages/register_success_debug_page.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_bloc.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_events.dart';
import 'package:viora_app/features/splash/representation/pages/splash.dart';

class AppRoutes {
  static const splash = '/';
  static const register = '/register';
  static const registerSuccess = '/register-success';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => BlocProvider(
        create: (_) => SplashBloc()..add(const SplashStarted()),
        child: const SplashPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.registerSuccess,
      builder: (context, state) {
        final submittedForm =
            (state.extra as Map<String, dynamic>?) ?? <String, dynamic>{};
        return RegisterSuccessDebugPage(submittedForm: submittedForm);
      },
    ),
  ],
);
