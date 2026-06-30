import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/organization/domain/usecases/get_organization_details_usecase.dart';
import 'package:viora_app/features/organization/representation/bloc/organization_event.dart';
import 'package:viora_app/features/organization/representation/bloc/organization_state.dart';

class OrganizationBloc extends Bloc<OrganizationEvent, OrganizationState> {
  final GetOrganizationDetailsUseCase getOrganizationDetailsUseCase;

  OrganizationBloc({required this.getOrganizationDetailsUseCase})
      : super(const OrganizationInitial()) {
    on<GetOrganizationDetail>(_onGetOrganizationDetail);
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
}
