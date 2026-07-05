import 'package:equatable/equatable.dart';
import 'package:viora_app/features/staff/domain/entities/staff.dart';

sealed class StaffState extends Equatable {
  const StaffState();

  @override
  List<Object?> get props => [];
}

final class StaffInitial extends StaffState {
  const StaffInitial();
}

final class StaffLoading extends StaffState {
  const StaffLoading();
}

final class StaffLoaded extends StaffState {
  final List<Staff> staff;
  final String branchId;
  final String serviceId;

  const StaffLoaded({
    required this.staff,
    required this.branchId,
    required this.serviceId,
  });

  @override
  List<Object?> get props => [staff, branchId, serviceId];
}

final class StaffError extends StaffState {
  final String message;

  const StaffError(this.message);

  @override
  List<Object?> get props => [message];
}
