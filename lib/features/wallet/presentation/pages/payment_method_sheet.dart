import 'package:flutter/material.dart';

enum PaymentMethod { wallet, cash }

class PaymentMethodSheet extends StatelessWidget {
  final double serviceCost;
  final double walletBalance;

  const PaymentMethodSheet({
    super.key,
    required this.serviceCost,
    required this.walletBalance,
  });

  @override
  Widget build(BuildContext context) {
    final canPayWithWallet = walletBalance >= serviceCost;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Service cost: \$${serviceCost.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),

          // Wallet option
          _PaymentOptionCard(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Wallet',
            subtitle: canPayWithWallet
                ? 'Balance: \$${walletBalance.toStringAsFixed(2)}'
                : 'Insufficient balance (\$${walletBalance.toStringAsFixed(2)})',
            trailing: canPayWithWallet
                ? const Icon(Icons.check_circle, color: Color(0xFF0D7C66), size: 22)
                : const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 22),
            isEnabled: canPayWithWallet,
            onTap: canPayWithWallet
                ? () => Navigator.of(context).pop(PaymentMethod.wallet)
                : null,
          ),
          const SizedBox(height: 12),

          // Cash option
          _PaymentOptionCard(
            icon: Icons.money_outlined,
            title: 'Cash',
            subtitle: 'Pay at the branch after service',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
            isEnabled: true,
            onTap: () => Navigator.of(context).pop(PaymentMethod.cash),
          ),
        ],
      ),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _PaymentOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.isEnabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled
                ? const Color(0xFFE8E8EE)
                : const Color(0xFFF3F4F6),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isEnabled
                    ? const Color(0xFFF0FCF8)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isEnabled
                    ? const Color(0xFF0D7C66)
                    : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isEnabled
                          ? const Color(0xFF1A1A2E)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isEnabled
                          ? const Color(0xFF6B7280)
                          : const Color(0xFFD1D5DB),
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
