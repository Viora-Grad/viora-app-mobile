import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/auth/domain/entities/user.dart';
import 'package:viora_app/features/auth/domain/repositories/auth_local_repository.dart';

// Brief: This is the GetCurrentUserUsecase, which is responsible for retrieving
// the currently logged-in user from the local repository. It returns an Either<Failure, User>
// to handle success and failure cases explicitly, allowing the caller to manage
// errors effectively in the domain layer.

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
