import 'package:equatable/equatable.dart';

class AiAction extends Equatable {
  final String label;
  final String actionType;
  final String specialty;
  final String? orgName;
  final String? country;
  final String? serviceType;
  final double? minRating;

  const AiAction({
    required this.label,
    this.actionType = 'specialty',
    this.specialty = '',
    this.orgName,
    this.country,
    this.serviceType,
    this.minRating,
  });

  bool get isOrgSearch => actionType == 'orgSearch';

  @override
  List<Object?> get props => [
        label,
        actionType,
        specialty,
        orgName,
        country,
        serviceType,
        minRating,
      ];
}
