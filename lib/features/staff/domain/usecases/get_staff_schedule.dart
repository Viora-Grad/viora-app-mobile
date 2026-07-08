import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/staff/domain/entities/staff_shift.dart';
import 'package:viora_app/features/staff/domain/repositories/staff_repository.dart';

class GetStaffScheduleUseCase {
  final StaffRepository repository;

  GetStaffScheduleUseCase(this.repository);

  Future<Either<Failure, List<StaffShift>>> call(String branchId) async {
    if (branchId.isEmpty) {
      return const Left(ValidationFailure('Branch ID is required'));
    }
    return repository.getBranchSchedule(branchId);
  }
}
