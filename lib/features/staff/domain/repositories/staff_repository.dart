import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/staff/domain/entities/staff.dart';
import 'package:viora_app/features/staff/domain/entities/staff_shift.dart';

abstract class StaffRepository {
  Future<Either<Failure, List<Staff>>> getStaffByBranchService(
    String branchId,
    String serviceId,
  );

  Future<Either<Failure, List<StaffShift>>> getBranchSchedule(
    String branchId,
  );
}
