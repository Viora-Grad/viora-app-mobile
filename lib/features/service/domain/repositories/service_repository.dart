import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/service/domain/entities/service.dart';

abstract class ServiceRepository {
  Future<Either<Failure, List<Service>>> getServicesByBranch(String branchId);
}
