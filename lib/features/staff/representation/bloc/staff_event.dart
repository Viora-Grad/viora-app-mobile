import 'package:equatable/equatable.dart';

sealed class StaffEvent extends Equatable {
  const StaffEvent();

  @override
  List<Object?> get props => [];
}

final class LoadStaff extends StaffEvent {
  final String branchId;
  final String serviceId;

  const LoadStaff({
    required this.branchId,
    required this.serviceId,
  });

  @override
  List<Object?> get props => [branchId, serviceId];
}
