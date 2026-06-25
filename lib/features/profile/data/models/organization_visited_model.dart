class OrganizationVisitsModel {
  final String organizationId;
  final DateTime visitedAt;

  OrganizationVisitsModel({
    required this.organizationId,
    required this.visitedAt,
  });

  factory OrganizationVisitsModel.fromJson(Map<String, dynamic> json) {
    return OrganizationVisitsModel(
      organizationId: json['organizationId'] as String? ?? '',
      visitedAt:
          DateTime.tryParse(json['visitedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
    'organizationId': organizationId,
    'visitedAt': visitedAt.toIso8601String(),
  };
}
