import 'package:viora_app/features/Auth/domain/entities/user.dart';
import 'package:viora_app/core/errors/exceptions.dart';
import 'package:viora_app/features/Auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUsecase {
  final AuthRepository repository;

  GetCurrentUserUsecase(this.repository);

  Future<User> call() async {
    final currentUser = await repository.getCurrentUser();
    if (currentUser == null) {
      throw const ValidationException('No user is currently logged in');
    }
    return currentUser;
  }
}
