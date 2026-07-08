import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/features/forms/domain/entities/form_entity.dart';
import 'package:viora_app/features/forms/domain/usecases/get_service_form.dart';
import 'package:viora_app/features/forms/domain/usecases/submit_form_answer.dart';
import 'package:viora_app/features/forms/domain/usecases/upload_form_file.dart';
import 'package:viora_app/features/appointments/domain/usecases/book_appointment.dart';
import 'package:viora_app/features/forms/presentation/bloc/form_bloc.dart';
import 'package:viora_app/features/forms/presentation/pages/form_page.dart';

class MockGetServiceForm extends Mock implements GetServiceFormUseCase {}
class MockBookAppointment extends Mock implements BookAppointmentUseCase {}
class MockSubmitForm extends Mock implements SubmitFormAnswerUseCase {}
class MockUploadFile extends Mock implements UploadFormFileUseCase {}

void main() {
  setUpAll((){
    registerFallbackValue(AnswerData(id: 'a', type: 't', answer: 'v'));
  });

  testWidgets('FormPage loads form and submits', (tester) async {
    final mockGet = MockGetServiceForm();
    final mockBook = MockBookAppointment();
    final mockSubmit = MockSubmitForm();
    final mockUpload = MockUploadFile();

    final field = FormFieldEntity(id: 'q1', type: 'text', label: 'Q1', required: true);
    final form = FormEntity(id: 'f1', staffId: 's', serviceId: 'sv', name: 'Test Form', questions: [field]);

    when(() => mockGet.call(any())).thenAnswer((_) async => Right(form));
    when(() => mockBook.call(
      serviceId: any(named: 'serviceId'),
      staffId: any(named: 'staffId'),
      branchId: any(named: 'branchId'),
      reservationDate: any(named: 'reservationDate'),
      durationMinutes: any(named: 'durationMinutes'),
      paymentMethod: any(named: 'paymentMethod'),
    )).thenAnswer((_) async => const Right('appt-1'));
    when(() => mockSubmit.call(appointmentId: any(named: 'appointmentId'), formId: any(named: 'formId'), answers: any(named: 'answers')))
      .thenAnswer((_) async => const Right('submission-1'));
    when(() => mockUpload.call(formSubmissionId: any(named: 'formSubmissionId'), filePath: any(named: 'filePath'), fileName: any(named: 'fileName')))
      .thenAnswer((_) async => const Right(null));

    final bloc = FormBloc(
      getServiceForm: mockGet,
      bookAppointment: mockBook,
      submitFormAnswer: mockSubmit,
      uploadFormFile: mockUpload,
    );

    final router = GoRouter(
      initialLocation: '/form',
      routes: [
        GoRoute(
          path: '/form',
          builder: (_, __) => BlocProvider<FormBloc>.value(
            value: bloc,
            child: FormPage(
              serviceId: 'sv',
              staffId: 's',
              staffName: 'Dr',
              serviceName: 'Service',
              branchId: 'b',
              serviceDurationMinutes: 30,
              serviceCost: 10.0,
              reservationDate: DateTime.now(),
              paymentMethod: 'Cash',
            ),
          ),
        ),
        GoRoute(path: AppRoutes.myAppointments, builder: (_, __) => const SizedBox.shrink()),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    // Let bloc process LoadForm
    await tester.pumpAndSettle();

    expect(find.text('Test Form'), findsOneWidget);

    // Enter answer into text field
    await tester.enterText(find.byType(TextField).first, 'My answer');
    await tester.pumpAndSettle();

    // Tap submit button
    final submitFinder = find.textContaining('Submit & Book Appointment');
    expect(submitFinder, findsOneWidget);
    await tester.tap(submitFinder);
    await tester.pump();

    // After tapping, bookAppointment should be called once
    verify(() => mockBook.call(
      serviceId: 'sv',
      staffId: 's',
      branchId: 'b',
      reservationDate: any(named: 'reservationDate'),
      durationMinutes: 30,
      paymentMethod: 'Cash',
    )).called(1);
  });
}
