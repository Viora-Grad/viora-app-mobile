import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/core/widgets/bottom_nav_bar.dart';

const _primary = Color(0xFF2F1193);

/// Landing page for the "Wellness" tab — a hub of small quality-of-life
/// features (hydration, movement, body check, sleep) powered by Vivi.
class WellnessHubPage extends StatelessWidget {
  const WellnessHubPage({super.key});

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.push(AppRoutes.myAppointments);
      case 2:
        context.push(AppRoutes.aiChat);
      case 3:
        break; // already here
      case 4:
        context.go(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wellness',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Small daily habits, guided by Vivi 💜',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _FeatureCard(
                icon: Icons.water_drop_rounded,
                color: const Color(0xFF29B6F6),
                title: 'Water Reminder',
                subtitle: 'Get friendly nudges to stay hydrated.',
                onTap: () => context.push(AppRoutes.waterReminder),
              ),
              const SizedBox(height: 16),
              _FeatureCard(
                icon: Icons.fitness_center_rounded,
                color: const Color(0xFFFF7043),
                title: 'Workout Break',
                subtitle: 'Quick 5-minute movement reminders.',
                onTap: () => context.push(AppRoutes.workoutReminder),
              ),
              const SizedBox(height: 16),
              _FeatureCard(
                icon: Icons.monitor_weight_rounded,
                color: const Color(0xFF66BB6A),
                title: 'Body Check',
                subtitle: 'See if your weight suits your height.',
                onTap: () => context.push(AppRoutes.bmiCalculator),
              ),
              const SizedBox(height: 16),
              _FeatureCard(
                icon: Icons.bedtime_rounded,
                color: const Color(0xFF7E57C2),
                title: 'Sleep Tracker',
                subtitle: 'Log your sleep and get rest tips.',
                onTap: () => context.push(AppRoutes.sleepTracker),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8E8EE)),
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
