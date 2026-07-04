import 'package:equatable/equatable.dart';
import 'package:viora_app/features/wallet/domain/entities/wallet_transaction_entity.dart';

enum WalletType { customer, branch }

class WalletEntity extends Equatable {
  final String walletId;
  final WalletType walletType;
  final double balance;
  final String currency;
  final List<WalletTransactionEntity> transactions;

  const WalletEntity({
    required this.walletId,
    required this.walletType,
    required this.balance,
    required this.currency,
    this.transactions = const [],
  });

  @override
  List<Object?> get props => [
        walletId,
        walletType,
        balance,
        currency,
        transactions,
      ];
}
