import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/wallet/data/datasources/wallet_remote.dart';
import 'package:viora_app/features/wallet/domain/entities/wallet_entity.dart';
import 'package:viora_app/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remoteDataSource;

  WalletRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, WalletEntity>> openWallet() async {
    try {
      final model = await _remoteDataSource.openWallet();
      return Right(model.toEntity());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> getWallet({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final model = await _remoteDataSource.getWallet(
        page: page,
        pageSize: pageSize,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, String>> rechargeWallet(double amount) async {
    try {
      final paymentUrl = await _remoteDataSource.rechargeWallet(amount);
      return Right(paymentUrl);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
