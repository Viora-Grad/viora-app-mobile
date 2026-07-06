import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/features/auth/representation/pages/forgot_password_page.dart';
import 'package:viora_app/features/auth/representation/pages/login.dart';
import 'package:viora_app/features/auth/representation/pages/register.dart';
import 'package:viora_app/features/home/representation/pages/all_specialties_page.dart';
import 'package:viora_app/features/home/representation/pages/home_page.dart';
import 'package:viora_app/features/organization/representation/bloc/organization_bloc.dart';
import 'package:viora_app/features/organization/representation/pages/branch_detail_page.dart';
import 'package:viora_app/features/organization/representation/pages/organization_detail_page.dart';
import 'package:viora_app/features/organization/representation/pages/saved_organizations_page.dart';
import 'package:viora_app/features/organization/representation/pages/visited_organizations_page.dart';
import 'package:viora_app/features/profile/representation/pages/change_password_page.dart';
import 'package:viora_app/features/profile/representation/pages/medical_record_page.dart';
import 'package:viora_app/features/profile/representation/pages/profile.dart';
import 'package:viora_app/features/search/representation/bloc/search_bloc.dart';
import 'package:viora_app/features/search/representation/bloc/search_event.dart';
import 'package:viora_app/features/search/representation/pages/branch_search_page.dart';
import 'package:viora_app/features/search/representation/pages/search_page.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_bloc.dart';
import 'package:viora_app/features/splash/representation/blocs/splash_events.dart';
import 'package:viora_app/features/splash/representation/pages/splash.dart';
import 'package:viora_app/features/vivi/representation/pages/ai_chat_page.dart';
import 'package:viora_app/features/wellness/presentation/pages/bmi_calculator_page.dart';
import 'package:viora_app/features/wellness/presentation/pages/sleep_tracker_page.dart';
import 'package:viora_app/features/wellness/presentation/pages/water_reminder_page.dart';
import 'package:viora_app/features/service/representation/pages/service_listing_page.dart';
import 'package:viora_app/features/appointments/representation/bloc/appointment_bloc.dart';
import 'package:viora_app/features/appointments/representation/pages/appointment_booking_page.dart';
import 'package:viora_app/features/forms/presentation/bloc/form_bloc.dart';
import 'package:viora_app/features/forms/presentation/pages/form_page.dart';
import 'package:viora_app/features/staff/representation/pages/staff_listing_page.dart';
import 'package:viora_app/features/wellness/presentation/pages/wellness_hub_page.dart';
import 'package:viora_app/features/wellness/presentation/pages/workout_reminder_page.dart';
import 'package:viora_app/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:viora_app/features/wallet/presentation/pages/wallet_page.dart';
import 'package:viora_app/features/appointments/representation/bloc/user_appointments_bloc.dart';
import 'package:viora_app/features/appointments/representation/pages/user_appointments_page.dart';
import 'package:viora_app/features/appointments/representation/pages/appointment_detail_page.dart';
import 'package:viora_app/features/prescription/presentation/bloc/prescription_bloc.dart';
import 'package:viora_app/features/prescription/presentation/pages/prescription_page.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const profile = '/profile';
  static const search = '/search';
  static const branchSearch = '/branch-search';
  static const specialties = '/specialties';
  static const changePassword = '/change-password';
  static const forgotPassword = '/forgot-password';
  static const aiChat = '/ai-chat';
  static const organizationDetail = '/organization';
  static const branchDetail = '/branch-detail';
  static const savedOrganizations = '/saved-organizations';
  static const visitedOrganizations = '/visited-organizations';
  static const medicalRecord = '/medical-record';
  static const wellness = '/wellness';
  static const waterReminder = '/wellness/water';
  static const workoutReminder = '/wellness/workout';
  static const bmiCalculator = '/wellness/bmi';
  static const sleepTracker = '/wellness/sleep';
  static const serviceListing = '/services';
  static const staffListing = '/staff';
  static const bookAppointment = '/book-appointment';
  static const fillForm = '/fill-form';
  static const wallet = '/wallet';
  static const myAppointments = '/my-appointments';
  static const appointmentDetail = '/appointment-detail';
  static const prescription = '/prescription';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => BlocProvider(
        create: (_) => SplashBloc()..add(const SplashStarted()),
        child: const SplashPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: AppRoutes.changePassword,
      builder: (context, state) => const ChangePasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) {
        final query = state.uri.queryParameters['q'];
        final extra = state.extra as Map<String, dynamic>?;
        return BlocProvider(
          create: (_) => sl<SearchBloc>()..add(const LoadFilterOptions()),
          child: SearchPage(
            initialQuery: query ?? extra?['query'] as String?,
            initialCountry: extra?['country'] as String?,
            initialServiceType: extra?['serviceType'] as String?,
            initialMinRating: extra?['minRating'] as double?,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.branchSearch,
      builder: (context, state) {
        final specialty = state.extra as String? ?? '';
        return BlocProvider(
          create: (_) => sl<SearchBloc>(),
          child: BranchSearchPage(specialty: specialty),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.specialties,
      builder: (context, state) => const AllSpecialtiesPage(),
    ),
    GoRoute(
      path: AppRoutes.aiChat,
      builder: (context, state) => const AiChatPage(),
    ),
    GoRoute(
      path: AppRoutes.organizationDetail,
      builder: (context, state) {
        final params = state.uri.queryParameters;
        final orgId = params['id'] ?? state.extra as String? ?? '';
        final rating = params['rating'] != null ? double.tryParse(params['rating']!) : null;
        final ratingsCount = params['ratingsCount'] != null ? int.tryParse(params['ratingsCount']!) : null;
        return BlocProvider(
          create: (_) => sl<OrganizationBloc>(),
          child: OrganizationDetailPage(
            organizationId: orgId,
            initialRating: rating,
            initialRatingsCount: ratingsCount,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.branchDetail,
      builder: (context, state) {
        final params = state.uri.queryParameters;
        final branchId = params['id'] ?? state.extra as String? ?? '';
        return BlocProvider.value(
          value: sl<OrganizationBloc>(),
          child: BranchDetailPage(branchId: branchId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.savedOrganizations,
      builder: (context, state) => const SavedOrganizationsPage(),
    ),
    GoRoute(
      path: AppRoutes.visitedOrganizations,
      builder: (context, state) {
        final ids = (state.extra as List<String>?);
        return VisitedOrganizationsPage(organizationIds: ids ?? []);
      },
    ),
    GoRoute(
      path: AppRoutes.medicalRecord,
      builder: (context, state) {
        return MedicalRecordPage(existingRecord: state.extra as dynamic);
      },
    ),
    GoRoute(
      path: AppRoutes.wellness,
      builder: (context, state) => const WellnessHubPage(),
    ),
    GoRoute(
      path: AppRoutes.waterReminder,
      builder: (context, state) => const WaterReminderPage(),
    ),
    GoRoute(
      path: AppRoutes.workoutReminder,
      builder: (context, state) => const WorkoutReminderPage(),
    ),
    GoRoute(
      path: AppRoutes.bmiCalculator,
      builder: (context, state) => const BmiCalculatorPage(),
    ),
    GoRoute(
      path: AppRoutes.sleepTracker,
      builder: (context, state) => const SleepTrackerPage(),
    ),
    GoRoute(
      path: AppRoutes.serviceListing,
      builder: (context, state) {
        final params = state.uri.queryParameters;
        final branchId = params['branchId'] ?? '';
        final serviceType = params['type'] ?? '';
        return ServiceListingPage(
          branchId: branchId,
          serviceType: serviceType,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.staffListing,
      builder: (context, state) {
        final params = state.uri.queryParameters;
        final branchId = params['branchId'] ?? '';
        final serviceId = params['serviceId'] ?? '';
        final serviceName = params['serviceName'] ?? 'Doctors';
        final serviceDuration =
            int.tryParse(params['serviceDuration'] ?? '') ?? 30;
        final serviceCost =
            double.tryParse(params['serviceCost'] ?? '') ?? 0;
        return StaffListingPage(
          branchId: branchId,
          serviceId: serviceId,
          serviceName: Uri.decodeComponent(serviceName),
          serviceDuration: serviceDuration,
          serviceCost: serviceCost,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.fillForm,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return BlocProvider(
          create: (_) => sl<FormBloc>(),
          child: FormPage(
            serviceId: extra['serviceId'] as String? ?? '',
            staffId: extra['staffId'] as String? ?? '',
            staffName: extra['staffName'] as String? ?? '',
            serviceName: extra['serviceName'] as String? ?? '',
            branchId: extra['branchId'] as String? ?? '',
            serviceDurationMinutes: extra['serviceDurationMinutes'] as int? ?? 30,
            serviceCost: (extra['serviceCost'] as num?)?.toDouble() ?? 0,
            reservationDate: DateTime.tryParse(extra['reservationDate'] as String? ?? '') ?? DateTime.now(),
            paymentMethod: extra['paymentMethod'] as String? ?? 'Cash',
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.wallet,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<WalletBloc>(),
        child: const WalletPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.bookAppointment,
      builder: (context, state) {
        final params = state.uri.queryParameters;
        final staffId = params['staffId'] ?? '';
        final staffName =
            Uri.decodeComponent(params['staffName'] ?? 'Doctor');
        final serviceId = params['serviceId'] ?? '';
        final serviceName =
            Uri.decodeComponent(params['serviceName'] ?? 'Service');
        final branchId = params['branchId'] ?? '';
        final serviceDuration =
            int.tryParse(params['serviceDuration'] ?? '') ?? 30;
        final serviceCost =
            double.tryParse(params['serviceCost'] ?? '') ?? 0;
        return BlocProvider(
          create: (_) => sl<AppointmentBloc>(),
          child: AppointmentBookingPage(
            staffId: staffId,
            staffName: staffName,
            serviceId: serviceId,
            serviceName: serviceName,
            branchId: branchId,
            serviceDurationMinutes: serviceDuration,
            serviceCost: serviceCost,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.myAppointments,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<UserAppointmentsBloc>(),
        child: const UserAppointmentsPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.appointmentDetail,
      builder: (context, state) {
        final appointment = state.extra as dynamic;
        return AppointmentDetailPage(
          appointment: appointment,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.prescription,
      builder: (context, state) {
        final appointmentId = state.extra as String;
        return BlocProvider(
          create: (_) => sl<PrescriptionBloc>(),
          child: PrescriptionPage(appointmentId: appointmentId),
        );
      },
    ),
  ],
);
