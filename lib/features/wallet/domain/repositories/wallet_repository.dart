import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/wallet/domain/entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletEntity>> openWallet();

  Future<Either<Failure, WalletEntity>> getWallet({
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, String>> rechargeWallet(double amount);
}
