import 'package:equatable/equatable.dart';

enum TransactionType { credit, debit }

enum TransactionPurpose { recharge, payment, refund, checkout, payout }

class WalletTransactionEntity extends Equatable {
  final String id;
  final TransactionType type;
  final TransactionPurpose purpose;
  final double amount;
  final String currency;
  final double runningBalance;
  final String description;
  final String? referenceId;
  final DateTime createdAt;

  const WalletTransactionEntity({
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

  @override
  List<Object?> get props => [
        id,
        type,
        purpose,
        amount,
        currency,
        runningBalance,
        description,
        referenceId,
        createdAt,
      ];
}
