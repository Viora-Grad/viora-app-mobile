import 'package:equatable/equatable.dart';

class OrganizationDetail extends Equatable {
  final String id;
  final String name;
  final String about;
  final String country;
  final String countryCode;
  final List<String> servicesProvided;
  final String serviceDescription;
  final String contactEmail;
  final DateTime joinedOnUtc;
  final List<MinimalBranchDetail> branches;
  final String subDomain;

  const OrganizationDetail({
    required this.id,
    required this.name,
    required this.about,
    required this.country,
    required this.countryCode,
    required this.servicesProvided,
    required this.serviceDescription,
    required this.contactEmail,
    required this.joinedOnUtc,
    required this.branches,
    required this.subDomain,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        about,
        country,
        countryCode,
        servicesProvided,
        serviceDescription,
        contactEmail,
        joinedOnUtc,
        branches,
        subDomain,
      ];
}

class MinimalBranchDetail extends Equatable {
  final String id;
  final String? imageId;
  final String address;
  final DateTime openedSinceUtc;

  const MinimalBranchDetail({
    required this.id,
    this.imageId,
    required this.address,
    required this.openedSinceUtc,
  });

  @override
  List<Object?> get props => [id, imageId, address, openedSinceUtc];
}
