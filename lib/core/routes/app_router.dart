import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/features/auth/representation/pages/login.dart';
import 'package:viora_app/features/auth/representation/pages/register.dart';
import 'package:viora_app/features/home/representation/pages/home_page.dart';
import 'package:viora_app/features/profile/representation/pages/profile.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_bloc.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_events.dart';
import 'package:viora_app/features/splash/representation/pages/splash.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const profile = '/profile';
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
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfilePage(),
    ),
  ],
);
