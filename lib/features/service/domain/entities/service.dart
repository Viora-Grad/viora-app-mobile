import 'package:equatable/equatable.dart';

class Service extends Equatable {
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

  const Service({
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

  bool get hasActiveDiscount {
    if (discountPercentage == null || discountEndDate == null) return false;
    return DateTime.now().isBefore(discountEndDate!);
  }

  double get discountedCost {
    if (!hasActiveDiscount) return cost;
    return cost * (1 - discountPercentage! / 100);
  }

  @override
  List<Object?> get props => [
        id,
        branchId,
        name,
        description,
        serviceType,
        status,
        durationMinutes,
        cost,
        currency,
        discountPercentage,
        discountReason,
        discountStartDate,
        discountEndDate,
      ];
}
