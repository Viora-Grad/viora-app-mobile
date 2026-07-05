import 'package:viora_app/features/organization/data/models/branch_detail_model.dart';
import 'package:viora_app/features/organization/data/models/branch_schedule_model.dart';
import 'package:viora_app/features/organization/data/models/organization_detail_model.dart';

abstract class OrganizationRemote {
  Future<OrganizationDetailModel> getOrganizationDetails(String organizationId);

  Future<BranchDetailModel> getBranchDetails(String branchId);

  Future<List<BranchScheduleModel>> getBranchSchedule(String branchId);
}
