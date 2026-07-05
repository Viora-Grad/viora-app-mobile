import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local.dart';
import 'package:viora_app/features/appointments/representation/bloc/appointment_bloc.dart';
import 'package:viora_app/features/appointments/representation/bloc/appointment_event.dart';
import 'package:viora_app/features/appointments/representation/bloc/appointment_state.dart';
import 'package:viora_app/features/appointments/domain/entities/available_slot.dart';
import 'package:viora_app/features/appointments/domain/entities/reserved_appointment.dart';
import 'package:viora_app/features/appointments/representation/widgets/day_picker.dart';
import 'package:viora_app/features/appointments/representation/widgets/time_slot_grid.dart';
import 'package:viora_app/features/forms/domain/repositories/form_repository.dart';
import 'package:viora_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:viora_app/features/wallet/presentation/pages/payment_method_sheet.dart';

const Color _primary = Color(0xFF0D7C66);
const Color _accent = Color(0xFF14A085);
const Color _bg = Color(0xFFF0FCF8);
const Color _surface = Color(0xFFF7FFFD);
const Color _border = Color(0xFFC8E6DE);
const Color _textPrimary = Color(0xFF1A1A2E);
const Color _textSecondary = Color(0xFF6B7280);

class AppointmentBookingPage extends StatefulWidget {
  final String staffId;
  final String staffName;
  final String serviceId;
  final String serviceName;
  final String branchId;
  final int serviceDurationMinutes;
  final double serviceCost;

  const AppointmentBookingPage({
    super.key,
    required this.staffId,
    required this.staffName,
    required this.serviceId,
    required this.serviceName,
    required this.branchId,
    required this.serviceDurationMinutes,
    required this.serviceCost,
  });

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late DateTime _selectedDate;
  String _userName = '';
  String _selectedPaymentMethod = 'Cash';
  double? _walletBalance;
  bool _hasForm = false;
  bool _conflictShown = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _loadUserName();
    _loadAppointments();
    _loadWalletBalance();
    _checkHasForm();
  }

  Future<void> _checkHasForm() async {
    debugPrint('=== _checkHasForm ===');
    debugPrint('serviceId: ${widget.serviceId}');
    try {
      final repo = sl<FormRepository>();
      final result = await repo.getServiceForm(widget.serviceId);
      result.fold(
        (failure) {
          debugPrint('Form check failed: ${failure.message} (${failure.runtimeType})');
        },
        (form) {
          debugPrint('Form received: ${form != null}, questions: ${form?.questions.length}');
          if (mounted && form != null && form.questions.isNotEmpty) {
            debugPrint('Setting _hasForm = true');
            setState(() => _hasForm = true);
          } else {
            debugPrint('Not setting _hasForm: mounted=$mounted, form=${form != null}, questions=${form?.questions.length}');
          }
        },
      );
    } catch (e) {
      debugPrint('Form check error: $e');
    }
  }

  Future<void> _loadUserName() async {
    final authLocal = sl<AuthLocalDataSource>();
    final savedName = await authLocal.getUserName();
    if (savedName != null && savedName.isNotEmpty) {
      setState(() => _userName = savedName);
      return;
    }
    final user = await authLocal.getCurrentUser();
    if (user != null && mounted) {
      setState(() => _userName = '${user.firstName} ${user.lastName}'.trim());
    }
  }

  Future<void> _loadWalletBalance() async {
    try {
      final repo = sl<WalletRepository>();
      final result = await repo.getWallet();

      final failure = result.fold<Failure?>((f) => f, (_) => null);
      if (failure == null) {
        final wallet = result.fold((_) => null, (w) => w);
        if (mounted && wallet != null) {
          setState(() => _walletBalance = wallet.balance);
        }
        return;
      }

      if (failure is ServerFailure && failure.statusCode == 404) {
        await repo.openWallet();
        final retry = await repo.getWallet();
        retry.fold(
          (_) => null,
          (wallet) {
            if (mounted) setState(() => _walletBalance = wallet.balance);
          },
        );
      }
    } catch (_) {}
  }

  void _loadAppointments() {
    setState(() {
      _conflictShown = false;
    });
    context.read<AppointmentBloc>().add(LoadDoctorAppointments(
          branchId: widget.branchId,
          staffId: widget.staffId,
          serviceDurationMinutes: widget.serviceDurationMinutes,
          selectedDate: _selectedDate,
        ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _showPaymentMethodSheet() async {
    final balance = _walletBalance ?? 0;
    final method = await showModalBottomSheet<PaymentMethod>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PaymentMethodSheet(
        serviceCost: widget.serviceCost,
        walletBalance: balance,
      ),
    );

    if (method != null && mounted) {
      setState(() {
        _selectedPaymentMethod = method == PaymentMethod.wallet ? 'Wallet' : 'Cash';
      });
    }
  }

  void _confirmBooking() {
    final balance = _walletBalance ?? 0;
    if (_selectedPaymentMethod == 'Wallet' && balance < widget.serviceCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Insufficient wallet balance. Please choose Cash or top up.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: SnackBarAction(
            label: 'Top Up',
            textColor: Colors.white,
            onPressed: () => context.push(AppRoutes.wallet),
          ),
        ),
      );
      return;
    }

    final state = context.read<AppointmentBloc>().state;
    final startTime = state is DoctorAppointmentsLoaded ? state.manualStartTime : null;
    if (startTime == null) return;

    if (_hasForm) {
      _goToFormPage(startTime);
      return;
    }

    context.read<AppointmentBloc>().add(ConfirmBooking(
          serviceId: widget.serviceId,
          staffId: widget.staffId,
          branchId: widget.branchId,
          durationMinutes: widget.serviceDurationMinutes,
          paymentMethod: _selectedPaymentMethod,
        ));
  }

  void _goToFormPage(DateTime startTime) {
    context.push(
      AppRoutes.fillForm,
      extra: {
        'serviceId': widget.serviceId,
        'staffId': widget.staffId,
        'staffName': widget.staffName,
        'serviceName': widget.serviceName,
        'branchId': widget.branchId,
        'serviceDurationMinutes': widget.serviceDurationMinutes,
        'serviceCost': widget.serviceCost,
        'reservationDate': startTime.toIso8601String(),
        'paymentMethod': _selectedPaymentMethod,
      },
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state is BookingSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Appointment booked successfully!',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: _primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.pop();
        }

        if (state is DoctorAppointmentsLoaded &&
            state.conflictMessage != null &&
            !_conflictShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _conflictShown = true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.conflictMessage!),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'View Reserved',
                  textColor: Colors.white,
                  onPressed: () {
                    Scrollable.ensureVisible(
                      context,
                      alignment: 0.1,
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                ),
              ),
            );
          });
        }
      },
      child: Scaffold(
        backgroundColor: _surface,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildInfoCards(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Select Date'),
                        const SizedBox(height: 12),
                        _buildDayPicker(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Select Time'),
                        const SizedBox(height: 12),
                        _buildTimeInputSection(),
                        const SizedBox(height: 24),
                        _buildReservedTimesSection(),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 18, color: _textPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Book Appointment',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_primary, _accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.staffName.isNotEmpty
                    ? widget.staffName
                        .split(' ')
                        .map((n) => n.isNotEmpty ? n[0] : '')
                        .take(2)
                        .join()
                        .toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.staffName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.serviceName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${widget.serviceCost.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                '${widget.serviceDurationMinutes} min',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildMiniCard(
              Icons.calendar_today_rounded,
              _formatDate(_selectedDate),
              'Selected Date',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMiniCard(
              Icons.access_time_rounded,
              '${widget.serviceDurationMinutes} min',
              'Duration',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: _accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (title == 'Select Date')
            GestureDetector(
              onTap: () => _loadAppointments(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.refresh_rounded, size: 16, color: _primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayPicker() {
    return DayPickerWidget(
      selectedDate: _selectedDate,
      onDateSelected: (date) {
        setState(() {
          _selectedDate = date;
          _conflictShown = false;
        });
        context.read<AppointmentBloc>().add(LoadDoctorAppointments(
              branchId: widget.branchId,
              staffId: widget.staffId,
              serviceDurationMinutes: widget.serviceDurationMinutes,
              selectedDate: date,
            ));
      },
    );
  }

  Widget _buildTimeInputSection() {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        if (state is AppointmentsLoading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 14,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is AppointmentsError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.cloud_off_rounded,
                        size: 40, color: Color(0xFFEF4444)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to load data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: _textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _loadAppointments,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Try Again'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primary,
                      side: const BorderSide(color: _primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is DoctorAppointmentsLoaded) {
          final selectedSlot = state.manualStartTime != null
              ? AvailableSlot(
                  startTime: state.manualStartTime!,
                  endTime: state.calculatedEndTime!,
                )
              : null;
          return Column(
            children: [
              TimeSlotGrid(
                slots: state.availableSlots,
                selectedSlot: selectedSlot,
                onSlotSelected: (slot) {
                  setState(() => _conflictShown = false);
                  context.read<AppointmentBloc>().add(
                        SetAppointmentTime(startTime: slot.startTime),
                      );
                },
              ),
              const SizedBox(height: 16),
              if (state.manualStartTime != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTimeSummary(state),
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTimeSummary(DoctorAppointmentsLoaded state) {
    final start = state.manualStartTime!;
    final end = state.calculatedEndTime!;
    final startStr =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

    final hasConflict = state.conflictMessage != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasConflict ? const Color(0xFFFEF2F2) : _bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasConflict
              ? const Color(0xFFFECACA)
              : _primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              hasConflict
                  ? Icons.close_rounded
                  : Icons.check_circle_rounded,
              size: 20,
              color: hasConflict
                  ? const Color(0xFFEF4444)
                  : _primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$startStr - $endStr',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.serviceDurationMinutes} min appointment',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!hasConflict)
            Icon(Icons.check_circle, color: _primary, size: 20),
        ],
      ),
    );
  }

  Widget _buildReservedTimesSection() {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        if (state is! DoctorAppointmentsLoaded) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionTitle('Reserved Times'),
            ),
            const SizedBox(height: 12),
            if (state.reservedAppointments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_available_rounded,
                          size: 18, color: _accent),
                      const SizedBox(width: 10),
                      Text(
                        'No reservations yet for this day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.event_busy_rounded, size: 16,
                            color: const Color(0xFFEF4444)),
                        const SizedBox(width: 6),
                        Text(
                          '${state.reservedAppointments.length} reserved time${state.reservedAppointments.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...state.reservedAppointments.map(_buildReservedTimeChip),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildReservedTimeChip(ReservedAppointment apt) {
    final startStr =
        '${apt.reservationDate.hour.toString().padLeft(2, '0')}:${apt.reservationDate.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${apt.endTime.hour.toString().padLeft(2, '0')}:${apt.endTime.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFFFECACA).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.access_time_rounded,
                size: 16, color: Color(0xFFEF4444)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$startStr - $endStr',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF991B1B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        final loadedState =
            state is DoctorAppointmentsLoaded ? state : null;
        final hasTime = loadedState != null && loadedState.manualStartTime != null;
        final noConflict = hasTime && loadedState.conflictMessage == null;
        final isEnabled = noConflict && !loadedState.isBooking;
        final isBooking = loadedState?.isBooking ?? false;

        final buttonIcon = _hasForm
            ? Icons.assignment_rounded
            : (isBooking
                ? null
                : Icons.check_circle_rounded);
        final buttonLabel = isBooking
            ? 'Booking...'
            : _hasForm
                ? (isEnabled ? 'Next: Fill Form' : 'Select a start time')
                : (isEnabled ? 'Confirm Booking' : 'Select a start time');

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasTime) ...[
                    _buildCompactSummary(loadedState),
                    const SizedBox(height: 12),
                  ],
                  _buildPaymentMethodChip(),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: isEnabled ? _confirmBooking : null,
                      icon: isBooking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Icon(buttonIcon),
                      label: Text(
                        buttonLabel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade100,
                        disabledForegroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: isEnabled ? 4 : 0,
                        shadowColor: _primary.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactSummary(DoctorAppointmentsLoaded state) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final d = _selectedDate;
    final dateStr = '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
    final start = state.manualStartTime!;
    final end = state.calculatedEndTime!;
    final startStr =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long_rounded, size: 18, color: _primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName.isNotEmpty ? _userName : 'Customer',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateStr  ·  $startStr - $endStr',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${widget.serviceCost.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _primary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodChip() {
    final isWallet = _selectedPaymentMethod == 'Wallet';
    final balance = _walletBalance ?? 0;
    final hasBalance = balance >= widget.serviceCost;

    return GestureDetector(
      onTap: _showPaymentMethodSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Icon(
              isWallet ? Icons.account_balance_wallet_outlined : Icons.money_outlined,
              size: 18,
              color: _primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pay with $_selectedPaymentMethod',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  if (isWallet)
                    Text(
                      hasBalance
                          ? 'Balance: \$${balance.toStringAsFixed(2)}'
                          : 'Insufficient balance',
                      style: TextStyle(
                        fontSize: 11,
                        color: hasBalance ? _textSecondary : Colors.red,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: _textSecondary),
          ],
        ),
      ),
    );
  }
}
