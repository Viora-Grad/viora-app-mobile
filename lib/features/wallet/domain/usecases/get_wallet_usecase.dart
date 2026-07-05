import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/wallet/domain/entities/wallet_entity.dart';
import 'package:viora_app/features/wallet/domain/repositories/wallet_repository.dart';

class GetWalletUseCase {
  final WalletRepository repository;

  GetWalletUseCase(this.repository);

  Future<Either<Failure, WalletEntity>> call({
    int page = 1,
    int pageSize = 20,
  }) async {
    return repository.getWallet(page: page, pageSize: pageSize);
  }
}
