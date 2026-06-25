class MedicalRecordModel {
  final String id;
  final Map<String, dynamic> data;

  MedicalRecordModel({required this.id, required this.data});

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['id'] as String? ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'data': data};
}
