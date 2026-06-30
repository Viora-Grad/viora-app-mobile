import 'package:viora_app/features/search/domain/entities/organization.dart';

class OrganizationModel {
  final String id;
  final String? logoId;
  final String name;
  final String country;
  final String serviceDescription;
  final List<String> servicesProvided;
  final int ratingsCount;
  final double ratingOutOfTen;

  const OrganizationModel({
    required this.id,
    this.logoId,
    required this.name,
    required this.country,
    required this.serviceDescription,
    required this.servicesProvided,
    required this.ratingsCount,
    required this.ratingOutOfTen,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'] as String? ?? '',
      logoId: json['logoId'] as String?,
      name: json['name'] as String? ?? '',
      country: json['country'] as String? ?? '',
      serviceDescription: json['serviceDescription'] as String? ?? '',
      servicesProvided: (json['servicesProvided'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      ratingsCount: json['ratingsCount'] as int? ?? 0,
      ratingOutOfTen: (json['ratingOutOfTen'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Organization toEntity() {
    return Organization(
      id: id,
      logoId: logoId,
      name: name,
      country: country,
      serviceDescription: serviceDescription,
      servicesProvided: servicesProvided,
      ratingsCount: ratingsCount,
      ratingOutOfTen: ratingOutOfTen,
    );
  }
}

class PaginatedOrganizationsModel {
  final List<OrganizationModel> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginatedOrganizationsModel({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedOrganizationsModel.fromJson(Map<String, dynamic> json) {
    return PaginatedOrganizationsModel(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) =>
                  OrganizationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      totalCount: json['totalCount'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
    );
  }

  PaginatedOrganizations toEntity() {
    return PaginatedOrganizations(
      items: items.map((m) => m.toEntity()).toList(),
      page: page,
      pageSize: pageSize,
      totalCount: totalCount,
      totalPages: totalPages,
      hasNextPage: hasNextPage,
      hasPreviousPage: hasPreviousPage,
    );
  }
}
