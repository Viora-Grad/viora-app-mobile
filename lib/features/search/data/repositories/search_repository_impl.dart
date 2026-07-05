import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/exceptions.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/search/data/datasources/remote/search_remote.dart';
import 'package:viora_app/features/search/domain/entities/branch.dart';
import 'package:viora_app/features/search/domain/entities/organization.dart';
import 'package:viora_app/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemote searchRemote;

  SearchRepositoryImpl(this.searchRemote);

  @override
  Future<Either<Failure, PaginatedOrganizations>> searchOrganizations({
    String? name,
    String? country,
    String? serviceType,
    double minimumRating = 0.0,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final result = await searchRemote.searchOrganizations(
        name: name,
        country: country,
        serviceType: serviceType,
        minimumRating: minimumRating,
        sortBy: sortBy,
        page: page,
        pageSize: pageSize,
      );
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
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
  }) async {
    try {
      final result = await searchRemote.searchBranches(
        latitude: latitude,
        longitude: longitude,
        distanceWithinMeters: distanceWithinMeters,
        servicesFilter: servicesFilter,
        minimumRating: minimumRating,
        orderBy: orderBy,
        isCurrentlyOpen: isCurrentlyOpen,
        page: page,
        pageSize: pageSize,
      );
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCountries() async {
    try {
      final result = await searchRemote.getCountries();
      return Right(result);
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getServiceTypes() async {
    try {
      final result = await searchRemote.getServiceTypes();
      return Right(result);
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
