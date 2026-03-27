import 'package:viora_app/features/Auth/domain/entities/user.dart';
import 'package:viora_app/features/Auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUsecase {
    final Authrepository repository;
  
    GetCurrentUserUsecase(this.repository);
  
    Future<User> call() async {
      try {
        final currentUser = await repository.getCurrentUser();
        if (currentUser == null) {
          throw Exception('No user is currently logged in');
        }
        return currentUser;
      } catch (e) {
        throw Exception('Failed to get current user: $e');
      }
    }
}