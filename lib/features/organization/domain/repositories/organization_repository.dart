import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/organization/domain/entities/organization_detail.dart';

abstract class OrganizationRepository {
  Future<Either<Failure, OrganizationDetail>> getOrganizationDetails(
      String organizationId);
}
