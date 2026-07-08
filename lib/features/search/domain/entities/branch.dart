import 'package:equatable/equatable.dart';

class Branch extends Equatable {
  final String branchId;
  final String organizationId;
  final String organizationName;
  final bool isOpen;
  final DateTime openedSince;
  final double rating;
  final String status;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? coverImageUrl;

  const Branch({
    required this.branchId,
    required this.organizationId,
    required this.organizationName,
    required this.isOpen,
    required this.openedSince,
    required this.rating,
    required this.status,
    required this.address,
    this.latitude,
    this.longitude,
    this.coverImageUrl,
  });

  @override
  List<Object?> get props => [
        branchId,
        organizationId,
        organizationName,
        isOpen,
        openedSince,
        rating,
        status,
        address,
        latitude,
        longitude,
        coverImageUrl,
      ];
}

class PaginatedBranches extends Equatable {
  final List<Branch> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginatedBranches({
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
