import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/core/widgets/bottom_nav_bar.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/ai_banner.dart';
import '../widgets/health_dashboard.dart';
import '../widgets/popular_specialties.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        // TODO: Navigate to Bookings
        break;
      case 2:
        // TODO: Navigate to Vivi
        break;
      case 3:
        // TODO: Navigate to Wallet
        break;
      case 4:
        context.go(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(authLocal: sl<AuthLocalDataSource>())..add(LoadHomeDataEvent()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading || state is HomeInitial) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF2F1193)));
              }

              if (state is HomeLoaded) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, state.userName),
                      const SizedBox(height: 24),
                      _buildSearchBar(),
                      const SizedBox(height: 20),
                      const AiBanner(),
                      const SizedBox(height: 28),
                      const PopularSpecialties(),
                      const SizedBox(height: 28),
                      const HealthDashboard(),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              }

              return const Center(child: Text('Something went wrong.'));
            },
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
    final greeting = _getGreeting();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting,',
              style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              userName.isNotEmpty ? userName : 'Guest',
              style: const TextStyle(fontSize: 26, color: Colors.black, fontWeight: FontWeight.bold),
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
                child: Icon(Icons.notifications_none_outlined, color: Colors.black, size: 26),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Color(0xFF4A37A0), size: 24),
          hintText: 'Find doctors, clinics, salons...',
          hintStyle: TextStyle(color: Color(0xFF9E94C5), fontSize: 16),
          border: InputBorder.none,
          suffixIcon: Icon(Icons.tune, color: Color(0xFF4A37A0)),
        ),
      ),
    );
  }
}
