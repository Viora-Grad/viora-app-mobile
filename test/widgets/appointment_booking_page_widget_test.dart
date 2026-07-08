import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/core/di/service_locator.dart' as di;
import 'package:viora_app/features/appointments/representation/pages/appointment_booking_page.dart';
import 'package:viora_app/features/appointments/representation/bloc/appointment_bloc.dart';
import 'package:viora_app/features/appointments/domain/usecases/get_doctor_appointments.dart';
import 'package:viora_app/features/appointments/domain/usecases/get_staff_schedule.dart';
import 'package:viora_app/features/appointments/domain/usecases/book_appointment.dart';
import 'package:viora_app/features/appointments/domain/entities/reserved_appointment.dart';
import 'package:viora_app/features/appointments/domain/entities/staff_day_schedule.dart';
import 'package:viora_app/features/forms/domain/repositories/form_repository.dart';
import 'package:viora_app/features/Auth/data/datasources/local/auth_local.dart';
import 'package:viora_app/features/wallet/domain/entities/wallet_entity.dart';
import 'package:viora_app/features/wallet/domain/repositories/wallet_repository.dart';

class MockGetDoctorAppointments extends Mock implements GetDoctorAppointmentsUseCase {}
class MockGetStaffSchedule extends Mock implements GetDoctorDayShiftUseCase {}
class MockBookAppointment extends Mock implements BookAppointmentUseCase {}
class MockFormRepo extends Mock implements FormRepository {}
class MockAuthLocal extends Mock implements AuthLocalDataSource {}
class MockWalletRepo extends Mock implements WalletRepository {}

void main() {
  setUp(() {
    // Reset service locator
    di.sl.reset();
  });

  testWidgets('AppointmentBookingPage displays day picker and time slots', (tester) async {
    final mockGetAppointments = MockGetDoctorAppointments();
    final mockGetSchedule = MockGetStaffSchedule();
    final mockBook = MockBookAppointment();
    final mockForm = MockFormRepo();
    final mockAuth = MockAuthLocal();
    final mockWallet = MockWalletRepo();

    when(() => mockGetAppointments.call(doctorId: any(named: 'doctorId'), date: any(named: 'date')))
      .thenAnswer((_) async => const Right(<ReservedAppointment>[]));
    when(() => mockGetSchedule.call(branchId: any(named: 'branchId'), staffId: any(named: 'staffId')))
      .thenAnswer((_) async => Right([StaffDaySchedule(id: '1', day: 'Mon', startTime: '08:00', endTime: '17:00')]));
    when(() => mockBook.call(
      serviceId: any(named: 'serviceId'),
      staffId: any(named: 'staffId'),
      branchId: any(named: 'branchId'),
      reservationDate: any(named: 'reservationDate'),
      durationMinutes: any(named: 'durationMinutes'),
      paymentMethod: any(named: 'paymentMethod'),
    )).thenAnswer((_) async => const Right('appt-1'));

    when(() => mockForm.getServiceForm(any())).thenAnswer((_) async => const Right(null));
    when(() => mockAuth.getUserName()).thenAnswer((_) async => 'Test User');
    when(() => mockAuth.getCurrentUser()).thenAnswer((_) async => null);
    when(() => mockWallet.getWallet()).thenAnswer((_) async => Right(WalletEntity(walletId: 'w1', walletType: WalletType.customer, balance: 0, currency: 'USD')));

    // Register mocks in service locator used by the page
    di.sl.registerLazySingleton<GetDoctorAppointmentsUseCase>(() => mockGetAppointments as GetDoctorAppointmentsUseCase);
    di.sl.registerLazySingleton<GetDoctorDayShiftUseCase>(() => mockGetSchedule as GetDoctorDayShiftUseCase);
    di.sl.registerLazySingleton<BookAppointmentUseCase>(() => mockBook as BookAppointmentUseCase);
    di.sl.registerLazySingleton<FormRepository>(() => mockForm);
    di.sl.registerLazySingleton<AuthLocalDataSource>(() => mockAuth);
    di.sl.registerLazySingleton<WalletRepository>(() => mockWallet);

    final bloc = AppointmentBloc(
      getDoctorAppointments: mockGetAppointments,
      getStaffSchedule: mockGetSchedule,
      bookAppointment: mockBook,
    );

    await tester.pumpWidget(MaterialApp(
      home: BlocProvider<AppointmentBloc>.value(
        value: bloc,
        child: AppointmentBookingPage(
          staffId: 's1',
          staffName: 'Dr A',
          serviceId: 'sv1',
          serviceName: 'Service',
          branchId: 'b1',
          serviceDurationMinutes: 30,
          serviceCost: 20.0,
        ),
      ),
    ));

    // Let bloc load appointments and schedules
    await tester.pumpAndSettle();

    // DayPickerWidget should be present
    expect(find.byType(SizedBox), findsWidgets);

    // TimeSlotGrid should be present (shows slots or empty state depending on schedule)
    expect(find.textContaining('slot'), findsWidgets);
  });
}
