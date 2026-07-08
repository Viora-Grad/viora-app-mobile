import 'package:equatable/equatable.dart';

sealed class OrganizationEvent extends Equatable {
  const OrganizationEvent();

  @override
  List<Object?> get props => [];
}

class GetOrganizationDetail extends OrganizationEvent {
  final String organizationId;

  const GetOrganizationDetail({required this.organizationId});

  @override
  List<Object?> get props => [organizationId];
}

class GetBranchDetail extends OrganizationEvent {
  final String branchId;

  const GetBranchDetail({required this.branchId});

  @override
  List<Object?> get props => [branchId];
}

class GetBranchSchedule extends OrganizationEvent {
  final String branchId;

  const GetBranchSchedule({required this.branchId});

  @override
  List<Object?> get props => [branchId];
}
