import 'package:viora_app/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:viora_app/features/wallet/domain/entities/wallet_entity.dart';

class WalletModel {
  final String walletId;
  final String walletType;
  final double balance;
  final String currency;
  final List<WalletTransactionModel> transactions;

  const WalletModel({
    required this.walletId,
    required this.walletType,
    required this.balance,
    required this.currency,
    this.transactions = const [],
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final txList = json['transactions'] as List? ?? [];
    return WalletModel(
      walletId: json['walletId'] as String? ?? '',
      walletType: json['walletType'] as String? ?? 'Customer',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'EGP',
      transactions: txList
          .map((e) =>
              WalletTransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  WalletEntity toEntity() {
    return WalletEntity(
      walletId: walletId,
      walletType:
          walletType.toLowerCase() == 'branch' ? WalletType.branch : WalletType.customer,
      balance: balance,
      currency: currency,
      transactions: transactions.map((t) => t.toEntity()).toList(),
    );
  }
}
