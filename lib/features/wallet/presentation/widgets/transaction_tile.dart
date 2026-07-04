import 'package:flutter/material.dart';
import 'package:viora_app/features/wallet/domain/entities/wallet_transaction_entity.dart';

class TransactionTile extends StatelessWidget {
  final WalletTransactionEntity transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == TransactionType.credit;
    final icon = isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final iconColor = isCredit ? const Color(0xFF0D7C66) : const Color(0xFFEF4444);
    final sign = isCredit ? '+' : '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8EE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description.isNotEmpty
                      ? transaction.description
                      : _purposeLabel(transaction.purpose),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(transaction.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '\$${transaction.runningBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _purposeLabel(TransactionPurpose purpose) {
    switch (purpose) {
      case TransactionPurpose.recharge:
        return 'Wallet Top Up';
      case TransactionPurpose.payment:
        return 'Appointment Payment';
      case TransactionPurpose.refund:
        return 'Refund';
      case TransactionPurpose.checkout:
        return 'Checkout';
      case TransactionPurpose.payout:
        return 'Payout';
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
