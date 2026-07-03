import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local.dart';
import 'package:viora_app/features/appointments/representation/bloc/appointment_bloc.dart';
import 'package:viora_app/features/appointments/representation/bloc/appointment_event.dart';
import 'package:viora_app/features/appointments/representation/bloc/appointment_state.dart';
import 'package:viora_app/features/appointments/domain/entities/available_slot.dart';
import 'package:viora_app/features/appointments/representation/widgets/day_picker.dart';
import 'package:viora_app/features/appointments/representation/widgets/time_slot_grid.dart';

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
    _loadSlots();
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

  void _loadSlots() {
    context.read<AppointmentBloc>().add(LoadAvailableSlots(
          branchId: widget.branchId,
          staffId: widget.staffId,
          serviceId: widget.serviceId,
          serviceDurationMinutes: widget.serviceDurationMinutes,
          selectedDate: _selectedDate,
        ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _confirmBooking(DateTime startTime) {
    context.read<AppointmentBloc>().add(ConfirmBooking(
          serviceId: widget.serviceId,
          staffId: widget.staffId,
          branchId: widget.branchId,
          durationMinutes: widget.serviceDurationMinutes,
        ));
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
                        _buildSectionTitle('Available Times'),
                        const SizedBox(height: 12),
                        _buildSlotsSection(),
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
              onTap: () => _loadSlots(),
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
        setState(() => _selectedDate = date);
        context.read<AppointmentBloc>().add(LoadAvailableSlots(
              branchId: widget.branchId,
              staffId: widget.staffId,
              serviceId: widget.serviceId,
              serviceDurationMinutes: widget.serviceDurationMinutes,
              selectedDate: date,
            ));
      },
    );
  }

  Widget _buildSlotsSection() {
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
                    'Finding available slots...',
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
                    'Unable to load slots',
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
                    onPressed: _loadSlots,
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
        if (state is SlotsLoaded) {
          return TimeSlotGrid(
            slots: state.slots,
            selectedSlot: state.selectedSlot,
            onSlotSelected: (slot) {
              context.read<AppointmentBloc>().add(SelectSlot(
                    startTime: slot.startTime,
                    endTime: slot.endTime,
                  ));
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomBar() {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        final isEnabled = state is SlotsLoaded &&
            state.selectedSlot != null &&
            !state.isBooking;
        final isBooking = state is SlotsLoaded && state.isBooking;
        final slot = state is SlotsLoaded ? state.selectedSlot : null;

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
                  if (slot != null) ...[
                    _buildCompactSummary(slot),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: isEnabled && state.selectedSlot != null
                          ? () => _confirmBooking(state.selectedSlot!.startTime)
                          : null,
                      icon: isBooking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_rounded),
                      label: Text(
                        isBooking
                            ? 'Booking...'
                            : isEnabled
                                ? 'Confirm Booking'
                                : 'Select a time slot',
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

  Widget _buildCompactSummary(AvailableSlot slot) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final d = _selectedDate;
    final dateStr = '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';

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
                  '$dateStr  ·  ${slot.formattedStart} - ${slot.formattedEnd}',
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
}
