import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/organization/domain/entities/branch_detail.dart';
import 'package:viora_app/features/organization/domain/entities/branch_schedule.dart';
import 'package:viora_app/features/organization/domain/usecases/get_branch_details_usecase.dart';
import 'package:viora_app/features/organization/domain/usecases/get_branch_schedule_usecase.dart';
import 'package:viora_app/features/organization/domain/usecases/get_organization_details_usecase.dart';
import 'package:viora_app/features/organization/representation/bloc/organization_event.dart';
import 'package:viora_app/features/organization/representation/bloc/organization_state.dart';

class OrganizationBloc extends Bloc<OrganizationEvent, OrganizationState> {
  final GetOrganizationDetailsUseCase getOrganizationDetailsUseCase;
  final GetBranchDetailsUseCase getBranchDetailsUseCase;
  final GetBranchScheduleUseCase getBranchScheduleUseCase;

  OrganizationBloc({
    required this.getOrganizationDetailsUseCase,
    required this.getBranchDetailsUseCase,
    required this.getBranchScheduleUseCase,
  }) : super(const OrganizationInitial()) {
    on<GetOrganizationDetail>(_onGetOrganizationDetail);
    on<GetBranchDetail>(_onGetBranchDetail);
    on<GetBranchSchedule>(_onGetBranchSchedule);
  }

  Future<void> _onGetOrganizationDetail(
    GetOrganizationDetail event,
    Emitter<OrganizationState> emit,
  ) async {
    emit(const OrganizationLoading());

    final result = await getOrganizationDetailsUseCase(
      GetOrganizationDetailsParams(organizationId: event.organizationId),
    );

    result.fold(
      (failure) => emit(OrganizationError(failure.message)),
      (organization) => emit(OrganizationLoaded(organization: organization)),
    );
  }

  Future<void> _onGetBranchDetail(
    GetBranchDetail event,
    Emitter<OrganizationState> emit,
  ) async {
    emit(const OrganizationLoading());

    final results = await Future.wait([
      getBranchDetailsUseCase(GetBranchDetailsParams(branchId: event.branchId)),
      getBranchScheduleUseCase(GetBranchScheduleParams(branchId: event.branchId)),
    ]);

    final branchResult = results[0] as Either<Failure, BranchDetail>;
    final scheduleResult = results[1] as Either<Failure, List<BranchSchedule>>;

    branchResult.fold(
      (failure) => emit(OrganizationError(failure.message)),
      (branch) {
        final schedule = scheduleResult.fold(
          (_) => <BranchSchedule>[],
          (list) => list,
        );
        emit(BranchDetailLoaded(branch: branch, schedule: schedule));
      },
    );
  }

  Future<void> _onGetBranchSchedule(
    GetBranchSchedule event,
    Emitter<OrganizationState> emit,
  ) async {
    final currentState = state;
    if (currentState is BranchDetailLoaded) {
      final result = await getBranchScheduleUseCase(
        GetBranchScheduleParams(branchId: event.branchId),
      );

      result.fold(
        (_) {},
        (schedule) => emit(BranchDetailLoaded(
          branch: currentState.branch,
          schedule: schedule,
        )),
      );
    }
  }
}
