import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/service/domain/entities/service.dart';
import 'package:viora_app/features/service/domain/repositories/service_repository.dart';

class GetServicesByBranchUseCase {
  final ServiceRepository repository;

  GetServicesByBranchUseCase(this.repository);

  Future<Either<Failure, List<Service>>> call(String branchId) async {
    if (branchId.isEmpty) {
      return const Left(ValidationFailure('Branch ID is required'));
    }
    return repository.getServicesByBranch(branchId);
  }
}
