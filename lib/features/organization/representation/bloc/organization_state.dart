import 'package:equatable/equatable.dart';
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

class OrganizationError extends OrganizationState {
  final String message;

  const OrganizationError(this.message);

  @override
  List<Object?> get props => [message];
}
