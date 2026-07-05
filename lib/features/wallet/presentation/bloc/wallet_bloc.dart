import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/wallet/domain/entities/wallet_entity.dart';
import 'package:viora_app/features/wallet/domain/usecases/get_wallet_usecase.dart';
import 'package:viora_app/features/wallet/domain/usecases/open_wallet_usecase.dart';
import 'package:viora_app/features/wallet/domain/usecases/recharge_wallet_usecase.dart';
import 'package:viora_app/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:viora_app/features/wallet/presentation/bloc/wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletUseCase getWalletUseCase;
  final OpenWalletUseCase openWalletUseCase;
  final RechargeWalletUseCase rechargeWalletUseCase;

  WalletBloc({
    required this.getWalletUseCase,
    required this.openWalletUseCase,
    required this.rechargeWalletUseCase,
  }) : super(const WalletState()) {
    on<LoadWallet>(_onLoadWallet);
    on<OpenWallet>(_onOpenWallet);
    on<RechargeWallet>(_onRechargeWallet);
  }

  Future<void> _onLoadWallet(
    LoadWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: WalletStatus.loading));

    WalletEntity? loadWallet(WalletEntity w) {
      emit(state.copyWith(status: WalletStatus.loaded, wallet: w));
      return w;
    }

    Failure? loadFailure(Failure f) {
      emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: f.message,
      ));
      return f;
    }

    final result = await getWalletUseCase(
      page: event.page,
      pageSize: event.pageSize,
    );

    final wallet = result.fold<WalletEntity?>((f) {
      if (f is ServerFailure && f.statusCode == 404) return null;
      loadFailure(f);
      return null;
    }, loadWallet);

    if (wallet != null) return;

    final openResult = await openWalletUseCase();
    final opened = openResult.fold<WalletEntity?>(
      (f) {
        loadFailure(f);
        return null;
      },
      (w) => w,
    );

    if (opened == null) return;

    final retry = await getWalletUseCase(
      page: event.page,
      pageSize: event.pageSize,
    );

    retry.fold(loadFailure, loadWallet);
  }

  Future<void> _onOpenWallet(
    OpenWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: WalletStatus.loading));

    final openResult = await openWalletUseCase();

    final opened = openResult.fold<WalletEntity?>(
      (failure) {
        emit(state.copyWith(
          status: WalletStatus.error,
          errorMessage: failure.message,
        ));
        return null;
      },
      (w) => w,
    );

    if (opened == null) return;

    final getResult = await getWalletUseCase(
      page: 1,
      pageSize: 20,
    );

    getResult.fold(
      (failure) => emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: failure.message,
      )),
      (wallet) => emit(state.copyWith(
        status: WalletStatus.loaded,
        wallet: wallet,
      )),
    );
  }

  Future<void> _onRechargeWallet(
    RechargeWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(
      status: WalletStatus.recharging,
      clearPaymentUrl: true,
    ));

    final result = await rechargeWalletUseCase(event.amount);

    result.fold(
      (failure) => emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: failure.message,
      )),
      (paymentUrl) => emit(state.copyWith(
        status: WalletStatus.success,
        paymentUrl: paymentUrl,
      )),
    );
  }
}
