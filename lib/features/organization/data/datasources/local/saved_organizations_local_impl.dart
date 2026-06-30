import 'dart:convert';
import 'package:viora_app/core/database/cache/cache_helper.dart';
import 'package:viora_app/features/organization/data/datasources/local/saved_organizations_local.dart';

class SavedOrganizationsLocalImpl implements SavedOrganizationsLocal {
  final CacheHelper cacheHelper;
  static const String _key = 'saved_organizations';

  SavedOrganizationsLocalImpl(this.cacheHelper);

  @override
  Future<List<SavedOrganization>> getSavedOrganizations() async {
    final data = await cacheHelper.getData(_key);
    if (data is List<String>) {
      return data.map((str) {
        final json = jsonDecode(str) as Map<String, dynamic>;
        return SavedOrganization.fromJson(json);
      }).toList();
    }
    return [];
  }

  @override
  Future<bool> isSaved(String organizationId) async {
    final orgs = await getSavedOrganizations();
    return orgs.any((o) => o.id == organizationId);
  }

  @override
  Future<void> toggleSaved({
    required String id,
    required String name,
    String? logoId,
  }) async {
    final orgs = await getSavedOrganizations();
    final existing = orgs.indexWhere((o) => o.id == id);

    if (existing >= 0) {
      orgs.removeAt(existing);
    } else {
      orgs.add(SavedOrganization(id: id, name: name, logoId: logoId));
    }

    final jsonList = orgs.map((o) => jsonEncode(o.toJson())).toList();
    await cacheHelper.saveData(_key, jsonList);
  }
}
