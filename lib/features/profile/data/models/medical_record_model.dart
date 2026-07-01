class MedicalRecordModel {
  final String id;
  final int systolic;
  final int diastolic;
  final double weight;
  final int heartRate;
  final int bloodGlucose;
  final List<String> allergies;

  const MedicalRecordModel({
    required this.id,
    required this.systolic,
    required this.diastolic,
    required this.weight,
    required this.heartRate,
    required this.bloodGlucose,
    this.allergies = const [],
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    int nested(String key) {
      final val = json[key];
      if (val is Map<String, dynamic>) {
        return val['value'] as int? ?? 0;
      }
      return val as int? ?? 0;
    }

    double nestedDouble(String key) {
      final val = json[key];
      if (val is Map<String, dynamic>) {
        return (val['value'] as num?)?.toDouble() ?? 0.0;
      }
      return (val as num?)?.toDouble() ?? 0.0;
    }

    List<String> parseAllergies(dynamic val) {
      if (val is List) {
        return val.map((e) {
          if (e is String) return e;
          if (e is Map<String, dynamic>) return e['value'] as String? ?? '';
          return e.toString();
        }).toList();
      }
      return [];
    }

    final bp = json['bloodPressure'];
    int systolic = 0, diastolic = 0;
    if (bp is Map<String, dynamic>) {
      systolic = bp['systolic'] as int? ?? 0;
      diastolic = bp['diastolic'] as int? ?? 0;
    }

    return MedicalRecordModel(
      id: json['id']?.toString() ?? '',
      systolic: systolic,
      diastolic: diastolic,
      weight: nestedDouble('weight'),
      heartRate: nested('heartRate'),
      bloodGlucose: nested('bloodGlucose'),
      allergies: parseAllergies(json['allergies']),
    );
  }

  Map<String, dynamic> toJson() => {
    'systolic': systolic,
    'diastolic': diastolic,
    'weight': weight,
    'heartRate': heartRate,
    'bloodGlucose': bloodGlucose,
    'allergies': allergies,
  };
}
