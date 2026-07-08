import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/staff/domain/entities/staff.dart';
import 'package:viora_app/features/staff/domain/repositories/staff_repository.dart';

class GetStaffByBranchServiceUseCase {
  final StaffRepository repository;

  GetStaffByBranchServiceUseCase(this.repository);

  Future<Either<Failure, List<Staff>>> call({
    required String branchId,
    required String serviceId,
  }) async {
    if (branchId.isEmpty) {
      return const Left(ValidationFailure('Branch ID is required'));
    }
    if (serviceId.isEmpty) {
      return const Left(ValidationFailure('Service ID is required'));
    }
    return repository.getStaffByBranchService(branchId, serviceId);
  }
}
