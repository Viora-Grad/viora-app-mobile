import 'package:equatable/equatable.dart';
import 'package:viora_app/features/wallet/domain/entities/wallet_entity.dart';

enum WalletStatus { initial, loading, loaded, recharging, success, error }

final class WalletState extends Equatable {
  final WalletStatus status;
  final WalletEntity? wallet;
  final String? paymentUrl;
  final String? errorMessage;

  const WalletState({
    this.status = WalletStatus.initial,
    this.wallet,
    this.paymentUrl,
    this.errorMessage,
  });

  bool get isLoading => status == WalletStatus.loading;
  bool get isRecharging => status == WalletStatus.recharging;

  WalletState copyWith({
    WalletStatus? status,
    WalletEntity? wallet,
    String? paymentUrl,
    String? errorMessage,
    bool clearPaymentUrl = false,
  }) {
    return WalletState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      paymentUrl: clearPaymentUrl ? null : (paymentUrl ?? this.paymentUrl),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, wallet, paymentUrl, errorMessage];
}
