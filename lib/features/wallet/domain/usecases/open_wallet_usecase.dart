import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/wallet/domain/entities/wallet_entity.dart';
import 'package:viora_app/features/wallet/domain/repositories/wallet_repository.dart';

class OpenWalletUseCase {
  final WalletRepository repository;

  OpenWalletUseCase(this.repository);

  Future<Either<Failure, WalletEntity>> call() async {
    return repository.openWallet();
  }
}
