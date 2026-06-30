import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/organization/domain/entities/organization_detail.dart';
import 'package:viora_app/features/organization/domain/repositories/organization_repository.dart';

class GetOrganizationDetailsUseCase {
  final OrganizationRepository repository;

  GetOrganizationDetailsUseCase(this.repository);

  Future<Either<Failure, OrganizationDetail>> call(
    GetOrganizationDetailsParams params,
  ) {
    return repository.getOrganizationDetails(params.organizationId);
  }
}

class GetOrganizationDetailsParams extends Equatable {
  final String organizationId;

  const GetOrganizationDetailsParams({required this.organizationId});

  @override
  List<Object?> get props => [organizationId];
}
