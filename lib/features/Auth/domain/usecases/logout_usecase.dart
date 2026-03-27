import 'package:viora_app/features/Auth/domain/repositories/auth_repository.dart';

class LogoutUsecase {
  final Authrepository repository;

  LogoutUsecase(this.repository);

  Future<void> call() async {
    // Perform any necessary cleanup or state management before logging out
    // For example, you might want to clear user data from local storage

    // Call the logout method on the repository
    await repository.logout();
  }
}