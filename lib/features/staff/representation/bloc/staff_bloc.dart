import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/staff/domain/entities/staff.dart';
import 'package:viora_app/features/staff/domain/entities/staff_shift.dart';
import 'package:viora_app/features/staff/domain/usecases/get_staff_by_branch_service.dart';
import 'package:viora_app/features/staff/domain/usecases/get_staff_schedule.dart';
import 'package:viora_app/features/staff/representation/bloc/staff_event.dart';
import 'package:viora_app/features/staff/representation/bloc/staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final GetStaffByBranchServiceUseCase getStaffByBranchService;
  final GetStaffScheduleUseCase getStaffSchedule;

  StaffBloc({
    required this.getStaffByBranchService,
    required this.getStaffSchedule,
  }) : super(const StaffInitial()) {
    on<LoadStaff>(_onLoadStaff);
  }

  Future<void> _onLoadStaff(
    LoadStaff event,
    Emitter<StaffState> emit,
  ) async {
    emit(const StaffLoading());

    final staffResult = await getStaffByBranchService(
      branchId: event.branchId,
      serviceId: event.serviceId,
    );

    await staffResult.fold(
      (failure) async => emit(StaffError(failure.message)),
      (staff) async {
        final scheduleResult = await getStaffSchedule(event.branchId);

        await scheduleResult.fold(
          (failure) async {
            emit(StaffLoaded(
              staff: staff,
              branchId: event.branchId,
              serviceId: event.serviceId,
            ));
          },
          (shifts) async {
            final staffWithShifts = _assignShifts(staff, shifts);
            emit(StaffLoaded(
              staff: staffWithShifts,
              branchId: event.branchId,
              serviceId: event.serviceId,
            ));
          },
        );
      },
    );
  }

  List<Staff> _assignShifts(List<Staff> staff, List<StaffShift> shifts) {
    return staff.map((s) {
      final staffShifts = shifts.where((sh) => sh.staffId == s.id).toList();
      return s.copyWith(shifts: staffShifts);
    }).toList();
  }
}
