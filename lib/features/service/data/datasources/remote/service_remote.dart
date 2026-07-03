import 'package:viora_app/features/service/data/models/service_model.dart';

abstract class ServiceRemoteDataSource {
  Future<List<ServiceModel>> getServicesByBranch(String branchId);
}
