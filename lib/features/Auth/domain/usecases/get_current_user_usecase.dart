import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/Auth/domain/entities/user.dart';
import 'package:viora_app/features/Auth/domain/repositories/auth_local_repository.dart';

class GetCurrentUserUsecase {
  final AuthLocalRepository repository;

  GetCurrentUserUsecase(this.repository);

  Future<Either<Failure, User>> call() async {
    final result = await repository.getCurrentUser();
    return result.fold(
      Left.new,
      (currentUser) => currentUser == null
          ? const Left(ValidationFailure('No user is currently logged in'))
          : Right(currentUser),
    );
  }
}
