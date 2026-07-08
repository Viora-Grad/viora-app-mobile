import 'package:equatable/equatable.dart';

class Organization extends Equatable {
  final String id;
  final String? logoId;
  final String name;
  final String country;
  final String serviceDescription;
  final List<String> servicesProvided;
  final int ratingsCount;
  final double ratingOutOfTen;

  const Organization({
    required this.id,
    this.logoId,
    required this.name,
    required this.country,
    required this.serviceDescription,
    required this.servicesProvided,
    required this.ratingsCount,
    required this.ratingOutOfTen,
  });

  @override
  List<Object?> get props => [
        id,
        logoId,
        name,
        country,
        serviceDescription,
        servicesProvided,
        ratingsCount,
        ratingOutOfTen,
      ];
}

class PaginatedOrganizations extends Equatable {
  final List<Organization> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginatedOrganizations({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  @override
  List<Object?> get props => [
        items,
        page,
        pageSize,
        totalCount,
        totalPages,
        hasNextPage,
        hasPreviousPage,
      ];
}
