import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/features/wallet/domain/repositories/wallet_repository.dart';

class HealthDashboard extends StatefulWidget {
  const HealthDashboard({super.key});

  @override
  State<HealthDashboard> createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboard> {
  double _walletBalance = 0;
  bool _isLoadingWallet = true;

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    try {
      final repo = sl<WalletRepository>();
      final result = await repo.getWallet();

      final failure = result.fold<Failure?>((f) => f, (_) => null);
      if (failure == null) {
        final wallet = result.fold((_) => null, (w) => w);
        if (mounted && wallet != null) {
          setState(() {
            _walletBalance = wallet.balance;
            _isLoadingWallet = false;
          });
        }
        return;
      }

      if (failure is ServerFailure && failure.statusCode == 404) {
        await repo.openWallet();
        final retry = await repo.getWallet();
        retry.fold(
          (_) {
            if (mounted) setState(() => _isLoadingWallet = false);
          },
          (wallet) {
            if (mounted) {
              setState(() {
                _walletBalance = wallet.balance;
                _isLoadingWallet = false;
              });
            }
          },
        );
        return;
      }

      if (mounted) setState(() => _isLoadingWallet = false);
    } catch (_) {
      if (mounted) setState(() => _isLoadingWallet = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Health Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _DashboardCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Wallet',
                subtitle: _isLoadingWallet
                    ? 'Loading...'
                    : _walletBalance > 0
                        ? '\$${_walletBalance.toStringAsFixed(2)}'
                        : 'Add funds to start.',
                buttonLabel: _walletBalance > 0 ? 'View Wallet' : 'Top Up',
                isPrimary: true,
                onTap: () => context.push(AppRoutes.wallet),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _DashboardCard(
                icon: Icons.calendar_today_outlined,
                title: 'Visits',
                subtitle: 'View pending visits.',
                buttonLabel: 'View All',
                isPrimary: false,
                onTap: () => context.push(AppRoutes.myAppointments),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final bool isPrimary;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFFF0ECF9) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPrimary ? null : Border.all(color: const Color(0xFFE8E8EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPrimary
                  ? const Color(0xFF2F1193).withValues(alpha: 0.1)
                  : const Color(0xFFF5F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF2F1193), size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: isPrimary
                ? ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F1193),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2F1193),
                      side: const BorderSide(color: Color(0xFF2F1193)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
