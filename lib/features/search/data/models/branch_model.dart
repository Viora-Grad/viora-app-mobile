import 'package:viora_app/features/search/domain/entities/branch.dart';

class BranchModel {
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
  final CoverImageModel? coverImage;

  const BranchModel({
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
    this.coverImage,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'] as Map<String, dynamic>?;
    return BranchModel(
      branchId: json['branchId'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      organizationName: json['organizationName'] as String? ?? '',
      isOpen: json['isOpen'] as bool? ?? false,
      openedSince: json['openedSince'] != null
          ? DateTime.parse(json['openedSince'] as String)
          : DateTime.now(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] is int
          ? (json['status'] as int).toString()
          : (json['status'] as String? ?? 'Active'),
      address: json['address'] as String? ?? '',
      latitude: coordinates != null
          ? (coordinates['latitude'] as num?)?.toDouble()
          : null,
      longitude: coordinates != null
          ? (coordinates['longitude'] as num?)?.toDouble()
          : null,
      coverImage: json['coverImage'] != null
          ? CoverImageModel.fromJson(json['coverImage'] as Map<String, dynamic>)
          : null,
    );
  }

  Branch toEntity() {
    return Branch(
      branchId: branchId,
      organizationId: organizationId,
      organizationName: organizationName,
      isOpen: isOpen,
      openedSince: openedSince,
      rating: rating,
      status: status,
      address: address,
      latitude: latitude,
      longitude: longitude,
      coverImageUrl: coverImage?.fileName,
    );
  }
}

class CoverImageModel {
  final String id;
  final String contentType;
  final String fileName;
  final DateTime createdAt;

  const CoverImageModel({
    required this.id,
    required this.contentType,
    required this.fileName,
    required this.createdAt,
  });

  factory CoverImageModel.fromJson(Map<String, dynamic> json) {
    return CoverImageModel(
      id: json['id'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

class PaginatedBranchesModel {
  final List<BranchModel> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginatedBranchesModel({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedBranchesModel.fromJson(Map<String, dynamic> json) {
    return PaginatedBranchesModel(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => BranchModel.fromJson(e as Map<String, dynamic>))
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

  PaginatedBranches toEntity() {
    return PaginatedBranches(
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
