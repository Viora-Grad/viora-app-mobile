import 'package:viora_app/features/organization/data/models/organization_detail_model.dart';

abstract class OrganizationRemote {
  Future<OrganizationDetailModel> getOrganizationDetails(String organizationId);
}
