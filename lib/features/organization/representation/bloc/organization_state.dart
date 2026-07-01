import 'package:equatable/equatable.dart';
import 'package:viora_app/features/organization/domain/entities/branch_detail.dart';
import 'package:viora_app/features/organization/domain/entities/branch_schedule.dart';
import 'package:viora_app/features/organization/domain/entities/organization_detail.dart';

sealed class OrganizationState extends Equatable {
  const OrganizationState();

  @override
  List<Object?> get props => [];
}

class OrganizationInitial extends OrganizationState {
  const OrganizationInitial();
}

class OrganizationLoading extends OrganizationState {
  const OrganizationLoading();
}

class OrganizationLoaded extends OrganizationState {
  final OrganizationDetail organization;

  const OrganizationLoaded({required this.organization});

  @override
  List<Object?> get props => [organization];
}

class BranchDetailLoaded extends OrganizationState {
  final BranchDetail branch;
  final List<BranchSchedule> schedule;

  const BranchDetailLoaded({required this.branch, this.schedule = const []});

  @override
  List<Object?> get props => [branch, schedule];
}

class OrganizationError extends OrganizationState {
  final String message;

  const OrganizationError(this.message);

  @override
  List<Object?> get props => [message];
}
