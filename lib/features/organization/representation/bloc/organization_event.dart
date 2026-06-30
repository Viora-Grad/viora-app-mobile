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
