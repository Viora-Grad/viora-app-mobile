import 'package:viora_app/features/search/data/models/branch_model.dart';
import 'package:viora_app/features/search/data/models/organization_model.dart';

abstract class SearchRemote {
  Future<PaginatedOrganizationsModel> searchOrganizations({
    String? name,
    String? country,
    String? serviceType,
    double minimumRating,
    String? sortBy,
    int page,
    int pageSize,
  });

  Future<PaginatedBranchesModel> searchBranches({
    double? latitude,
    double? longitude,
    double? distanceWithinMeters,
    List<String>? servicesFilter,
    double minimumRating,
    List<String>? orderBy,
    bool? isCurrentlyOpen,
    int page,
    int pageSize,
  });

  Future<List<String>> getCountries();

  Future<List<String>> getServiceTypes();
}
