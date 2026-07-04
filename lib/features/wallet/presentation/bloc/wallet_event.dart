import 'package:equatable/equatable.dart';

sealed class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

final class LoadWallet extends WalletEvent {
  final int page;
  final int pageSize;

  const LoadWallet({this.page = 1, this.pageSize = 20});

  @override
  List<Object?> get props => [page, pageSize];
}

final class OpenWallet extends WalletEvent {
  const OpenWallet();
}

final class RechargeWallet extends WalletEvent {
  final double amount;

  const RechargeWallet(this.amount);

  @override
  List<Object?> get props => [amount];
}
