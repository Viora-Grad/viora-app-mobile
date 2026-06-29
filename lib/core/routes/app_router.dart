import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/features/auth/representation/pages/login.dart';
import 'package:viora_app/features/auth/representation/pages/register.dart';
import 'package:viora_app/features/home/representation/pages/all_specialties_page.dart';
import 'package:viora_app/features/home/representation/pages/home_page.dart';
import 'package:viora_app/features/profile/representation/pages/change_password_page.dart';
import 'package:viora_app/features/profile/representation/pages/profile.dart';
import 'package:viora_app/features/search/representation/bloc/search_bloc.dart';
import 'package:viora_app/features/search/representation/bloc/search_event.dart';
import 'package:viora_app/features/search/representation/pages/branch_search_page.dart';
import 'package:viora_app/features/search/representation/pages/search_page.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_bloc.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_events.dart';
import 'package:viora_app/features/splash/representation/pages/splash.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const profile = '/profile';
  static const search = '/search';
  static const branchSearch = '/branch-search';
  static const specialties = '/specialties';
  static const changePassword = '/change-password';
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
    GoRoute(
      path: AppRoutes.changePassword,
      builder: (context, state) => const ChangePasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) {
        final query = state.uri.queryParameters['q'];
        return BlocProvider(
          create: (_) => sl<SearchBloc>()..add(const LoadFilterOptions()),
          child: SearchPage(initialQuery: query),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.branchSearch,
      builder: (context, state) {
        final specialty = state.extra as String? ?? '';
        return BlocProvider(
          create: (_) => sl<SearchBloc>(),
          child: BranchSearchPage(specialty: specialty),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.specialties,
      builder: (context, state) => const AllSpecialtiesPage(),
    ),
  ],
);
