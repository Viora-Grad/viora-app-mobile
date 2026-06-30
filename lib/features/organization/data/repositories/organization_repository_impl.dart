import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/exceptions.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/organization/data/datasources/remote/organization_remote.dart';
import 'package:viora_app/features/organization/domain/entities/organization_detail.dart';
import 'package:viora_app/features/organization/domain/repositories/organization_repository.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final OrganizationRemote organizationRemote;

  OrganizationRepositoryImpl(this.organizationRemote);

  @override
  Future<Either<Failure, OrganizationDetail>> getOrganizationDetails(
      String organizationId) async {
    try {
      final result = await organizationRemote.getOrganizationDetails(
          organizationId);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
