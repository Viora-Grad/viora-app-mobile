import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/auth/domain/repositories/auth_repository.dart';

// Brief: This is the LogoutUsecase, which is responsible for handling the logout
// logic in the domain layer. It simply calls the logout method of the AuthRepository
// and returns an Either<Failure, void> to handle success and failure cases explicitly,
// allowing the caller to manage errors effectively in the domain layer.

class LogoutUsecase {
  final AuthRepository repository;

  LogoutUsecase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}
