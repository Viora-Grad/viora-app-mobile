import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/organization/domain/entities/branch_detail.dart';
import 'package:viora_app/features/organization/domain/repositories/organization_repository.dart';

class GetBranchDetailsUseCase {
  final OrganizationRepository repository;

  GetBranchDetailsUseCase(this.repository);

  Future<Either<Failure, BranchDetail>> call(
    GetBranchDetailsParams params,
  ) {
    return repository.getBranchDetails(params.branchId);
  }
}

class GetBranchDetailsParams extends Equatable {
  final String branchId;

  const GetBranchDetailsParams({required this.branchId});

  @override
  List<Object?> get props => [branchId];
}
