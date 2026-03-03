import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/user/domain/entities/user_entity.dart';
import 'package:viora_app/features/user/domain/repositories/user_repository.dart';

class GetUser {
  final UserRepository repository;

  GetUser(this.repository);

  Future<Either<Failure, UserEntity>> call(UserParameters parameters) async {
    return await repository.getUser(parameters);
  }
}