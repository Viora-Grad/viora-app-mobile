import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/wallet/domain/repositories/wallet_repository.dart';

class RechargeWalletUseCase {
  final WalletRepository _repository;

  RechargeWalletUseCase(this._repository);

  Future<Either<Failure, String>> call(double amount) async {
    if (amount <= 0) {
      return const Left(ValidationFailure('Amount must be greater than 0'));
    }
    if (amount > 100000) {
      return const Left(ValidationFailure('Amount cannot exceed 100,000'));
    }
    return _repository.rechargeWallet(amount);
  }
}
