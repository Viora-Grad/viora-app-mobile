abstract class SavedOrganizationsLocal {
  Future<List<SavedOrganization>> getSavedOrganizations();
  Future<bool> isSaved(String organizationId);
  Future<void> toggleSaved({
    required String id,
    required String name,
    String? logoId,
  });
}

class SavedOrganization {
  final String id;
  final String name;
  final String? logoId;

  const SavedOrganization({
    required this.id,
    required this.name,
    this.logoId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logoId': logoId,
      };

  factory SavedOrganization.fromJson(Map<String, dynamic> json) {
    return SavedOrganization(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      logoId: json['logoId'] as String?,
    );
  }
}
