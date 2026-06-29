import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/search/domain/entities/branch.dart';
import 'package:viora_app/features/search/domain/entities/organization.dart';

abstract class SearchRepository {
  Future<Either<Failure, PaginatedOrganizations>> searchOrganizations({
    String? name,
    String? country,
    String? serviceType,
    double minimumRating = 0.0,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, PaginatedBranches>> searchBranches({
    double? latitude,
    double? longitude,
    double? distanceWithinMeters,
    List<String>? servicesFilter,
    double minimumRating = 0.0,
    List<String>? orderBy,
    bool? isCurrentlyOpen,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, List<String>>> getCountries();

  Future<Either<Failure, List<String>>> getServiceTypes();
}
