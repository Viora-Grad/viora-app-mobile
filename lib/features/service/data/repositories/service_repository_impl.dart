import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/service/data/datasources/remote/service_remote.dart';
import 'package:viora_app/features/service/domain/entities/service.dart';
import 'package:viora_app/features/service/domain/repositories/service_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource remoteDataSource;

  ServiceRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Service>>> getServicesByBranch(
      String branchId) async {
    try {
      final models = await remoteDataSource.getServicesByBranch(branchId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
