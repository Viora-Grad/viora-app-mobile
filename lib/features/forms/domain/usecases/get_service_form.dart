import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/forms/domain/entities/form_entity.dart';
import 'package:viora_app/features/forms/domain/repositories/form_repository.dart';

class GetServiceFormUseCase {
  final FormRepository repository;

  GetServiceFormUseCase(this.repository);

  Future<Either<Failure, FormEntity?>> call(String serviceId) async {
    if (serviceId.isEmpty) {
      return const Left(ValidationFailure('Service ID is required'));
    }
    return repository.getServiceForm(serviceId);
  }
}
