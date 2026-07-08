import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:viora_app/features/organization/domain/repositories/organization_repository.dart';

class GetVisitedOrganizationIdsUseCase {
  final AppointmentRepository appointmentRepository;
  final OrganizationRepository organizationRepository;

  GetVisitedOrganizationIdsUseCase(
    this.appointmentRepository,
    this.organizationRepository,
  );

  Future<Either<Failure, List<String>>> call(String customerId) async {
    final appointmentsResult = await appointmentRepository.getCustomerAppointments(
      customerId,
      status: 'Completed',
    );

    return appointmentsResult.fold(
      (failure) => Left(failure),
      (appointments) async {
        final branchIds = appointments
            .where((a) => a.branchId.isNotEmpty)
            .map((a) => a.branchId)
            .toSet()
            .toList();

        final orgIds = <String>{};
        for (final branchId in branchIds) {
          final branchResult =
              await organizationRepository.getBranchDetails(branchId);
          branchResult.fold(
            (_) {},
            (branch) => orgIds.add(branch.organizationId),
          );
        }

        return Right(orgIds.toList());
      },
    );
  }
}
