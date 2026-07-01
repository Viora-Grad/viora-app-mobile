import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/core/widgets/bottom_nav_bar.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local.dart';
import 'package:viora_app/features/search/domain/usecases/search_organizations_usecase.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/ai_banner.dart';
import '../widgets/health_dashboard.dart';
import '../widgets/medical_record_banner.dart';
import '../widgets/popular_specialties.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late final HomeBloc _homeBloc;
  String _userName = '';
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    _homeBloc = HomeBloc(
      authLocal: sl<AuthLocalDataSource>(),
      searchOrganizationsUseCase: sl<SearchOrganizationsUseCase>(),
      getCountriesUseCase: sl<GetCountriesUseCase>(),
      getServiceTypesUseCase: sl<GetServiceTypesUseCase>(),
    )
      ..add(LoadHomeDataEvent())
      ..add(const LoadFilterOptionsEvent());

    _homeBloc.stream.listen((state) {
      if (!mounted) return;
      if (state is HomeLoaded && state.userName != _userName) {
        setState(() => _userName = state.userName);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_router == null) {
      _router = GoRouter.of(context);
      _router!.routerDelegate.addListener(_onRouteChanged);
    }
  }

  void _onRouteChanged() {
    final location = _router!.routerDelegate.currentConfiguration.uri.toString();
    if (location == AppRoutes.home && _currentIndex != 0) {
      setState(() => _currentIndex = 0);
    }
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        break;
      case 2:
        context.push(AppRoutes.aiChat);
        break;
      case 3:
        break;
      case 4:
        context.go(AppRoutes.profile);
    }
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_onRouteChanged);
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildSearchBar(),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoaded) {
                      return _buildMainContent();
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final greeting = _getGreeting();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting,',
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              _userName.isNotEmpty ? _userName : 'Guest',
              style: const TextStyle(
                  fontSize: 26,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F9),
                shape: BoxShape.circle,
              ),
              child: const Badge(
                alignment: Alignment.topRight,
                backgroundColor: Colors.red,
                smallSize: 8,
                child: Icon(Icons.notifications_none_outlined,
                    color: Colors.black, size: 26),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => context.go(AppRoutes.profile),
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFFFD1BA),
                child: Icon(Icons.person, color: Colors.brown),
              ),
            ),
          ],
        )
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => context.push('/search'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FC),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2F1193).withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF4A37A0), size: 24),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Search providers...',
                style: TextStyle(
                  color: Color(0xFF9E94C5),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.tune, color: Color(0xFF4A37A0)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          const AiBanner(),
          const SizedBox(height: 28),
          const PopularSpecialties(),
          const SizedBox(height: 28),
          const MedicalRecordBanner(),
          const SizedBox(height: 24),
          const HealthDashboard(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

}
