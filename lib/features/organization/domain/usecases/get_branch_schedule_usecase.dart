import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/organization/domain/entities/branch_schedule.dart';
import 'package:viora_app/features/organization/domain/repositories/organization_repository.dart';

class GetBranchScheduleUseCase {
  final OrganizationRepository repository;

  GetBranchScheduleUseCase(this.repository);

  Future<Either<Failure, List<BranchSchedule>>> call(
    GetBranchScheduleParams params,
  ) {
    return repository.getBranchSchedule(params.branchId);
  }
}

class GetBranchScheduleParams extends Equatable {
  final String branchId;

  const GetBranchScheduleParams({required this.branchId});

  @override
  List<Object?> get props => [branchId];
}
