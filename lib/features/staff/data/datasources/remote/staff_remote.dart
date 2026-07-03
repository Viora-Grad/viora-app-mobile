import 'package:viora_app/features/staff/data/models/staff_model.dart';

abstract class StaffRemoteDataSource {
  Future<List<StaffModel>> getStaffByBranchService(
    String branchId,
    String serviceId,
  );
}
