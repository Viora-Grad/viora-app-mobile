import 'package:viora_app/features/wallet/domain/entities/wallet_transaction_entity.dart';

class WalletTransactionModel {
  final String id;
  final String type;
  final String purpose;
  final double amount;
  final String currency;
  final double runningBalance;
  final String description;
  final String? referenceId;
  final DateTime createdAt;

  const WalletTransactionModel({
    required this.id,
    required this.type,
    required this.purpose,
    required this.amount,
    required this.currency,
    required this.runningBalance,
    required this.description,
    this.referenceId,
    required this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'Credit',
      purpose: json['purpose'] as String? ?? 'Recharge',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'EGP',
      runningBalance: (json['runningBalance'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      referenceId: json['referenceId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  WalletTransactionEntity toEntity() {
    return WalletTransactionEntity(
      id: id,
      type: type.toLowerCase() == 'credit'
          ? TransactionType.credit
          : TransactionType.debit,
      purpose: _parsePurpose(purpose),
      amount: amount,
      currency: currency,
      runningBalance: runningBalance,
      description: description,
      referenceId: referenceId,
      createdAt: createdAt,
    );
  }

  TransactionPurpose _parsePurpose(String p) {
    switch (p.toLowerCase()) {
      case 'recharge':
        return TransactionPurpose.recharge;
      case 'payment':
        return TransactionPurpose.payment;
      case 'refund':
        return TransactionPurpose.refund;
      case 'checkout':
        return TransactionPurpose.checkout;
      case 'payout':
        return TransactionPurpose.payout;
      default:
        return TransactionPurpose.recharge;
    }
  }
}
