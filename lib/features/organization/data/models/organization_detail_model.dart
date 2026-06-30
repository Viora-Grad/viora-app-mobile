import 'package:viora_app/features/organization/domain/entities/organization_detail.dart';

class OrganizationDetailModel {
  final String id;
  final String name;
  final String about;
  final String country;
  final String countryCode;
  final List<String> servicesProvided;
  final String serviceDescription;
  final String contactEmail;
  final DateTime joinedOnUtc;
  final List<MinimalBranchModel> branches;
  final String subDomain;

  const OrganizationDetailModel({
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

  factory OrganizationDetailModel.fromJson(Map<String, dynamic> json) {
    return OrganizationDetailModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      about: json['about'] as String? ?? '',
      country: json['country'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
      servicesProvided: (json['servicesProvided'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      serviceDescription: json['serviceDescription'] as String? ?? '',
      contactEmail: json['contactEmail'] as String? ?? '',
      joinedOnUtc: json['joinedOnUtc'] != null
          ? DateTime.parse(json['joinedOnUtc'] as String)
          : DateTime.now(),
      branches: (json['branches'] as List<dynamic>?)
              ?.map((e) =>
                  MinimalBranchModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      subDomain: json['subDomain'] as String? ?? '',
    );
  }

  OrganizationDetail toEntity() {
    return OrganizationDetail(
      id: id,
      name: name,
      about: about,
      country: country,
      countryCode: countryCode,
      servicesProvided: servicesProvided,
      serviceDescription: serviceDescription,
      contactEmail: contactEmail,
      joinedOnUtc: joinedOnUtc,
      branches: branches.map((b) => b.toEntity()).toList(),
      subDomain: subDomain,
    );
  }
}

class MinimalBranchModel {
  final String id;
  final String? imageId;
  final String address;
  final DateTime openedSinceUtc;

  const MinimalBranchModel({
    required this.id,
    this.imageId,
    required this.address,
    required this.openedSinceUtc,
  });

  factory MinimalBranchModel.fromJson(Map<String, dynamic> json) {
    return MinimalBranchModel(
      id: json['id'] as String? ?? '',
      imageId: json['imageId'] as String?,
      address: json['address'] as String? ?? '',
      openedSinceUtc: json['openedSinceUtc'] != null
          ? DateTime.parse(json['openedSinceUtc'] as String)
          : DateTime.now(),
    );
  }

  MinimalBranchDetail toEntity() {
    return MinimalBranchDetail(
      id: id,
      imageId: imageId,
      address: address,
      openedSinceUtc: openedSinceUtc,
    );
  }
}
