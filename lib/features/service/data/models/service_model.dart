import 'package:viora_app/features/service/domain/entities/service.dart';

class ServiceModel {
  final String id;
  final String branchId;
  final String name;
  final String description;
  final String serviceType;
  final String status;
  final int durationMinutes;
  final double cost;
  final String currency;
  final int? discountPercentage;
  final String? discountReason;
  final DateTime? discountStartDate;
  final DateTime? discountEndDate;

  const ServiceModel({
    required this.id,
    required this.branchId,
    required this.name,
    required this.description,
    required this.serviceType,
    required this.status,
    required this.durationMinutes,
    required this.cost,
    required this.currency,
    this.discountPercentage,
    this.discountReason,
    this.discountStartDate,
    this.discountEndDate,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final discount = json['discount'] as Map<String, dynamic>?;
    return ServiceModel(
      id: json['id'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      serviceType: json['serviceType'] as String? ?? '',
      status: json['status'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      discountPercentage: discount?['percentageOutOf100'] as int?,
      discountReason: discount?['reason'] as String?,
      discountStartDate: discount?['startDateUtc'] != null
          ? DateTime.tryParse(discount!['startDateUtc'] as String)
          : null,
      discountEndDate: discount?['endDateUtc'] != null
          ? DateTime.tryParse(discount!['endDateUtc'] as String)
          : null,
    );
  }

  Service toEntity() => Service(
        id: id,
        branchId: branchId,
        name: name,
        description: description,
        serviceType: serviceType,
        status: status,
        durationMinutes: durationMinutes,
        cost: cost,
        currency: currency,
        discountPercentage: discountPercentage,
        discountReason: discountReason,
        discountStartDate: discountStartDate,
        discountEndDate: discountEndDate,
      );
}
