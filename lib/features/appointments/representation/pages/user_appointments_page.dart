import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/features/appointments/domain/entities/reserved_appointment.dart';
import 'package:viora_app/features/appointments/representation/bloc/user_appointments_bloc.dart';
import 'package:viora_app/features/appointments/representation/bloc/user_appointments_event.dart';
import 'package:viora_app/features/appointments/representation/bloc/user_appointments_state.dart';
import 'package:viora_app/features/Auth/data/datasources/local/auth_local.dart';

const Color _primary = Color(0xFF0D7C66);
const Color _accent = Color(0xFF14A085);
const Color _bg = Color(0xFFF0FCF8);
const Color _border = Color(0xFFC8E6DE);
const Color _textPrimary = Color(0xFF1A1A2E);
const Color _textSecondary = Color(0xFF6B7280);

const List<String> _statusOptions = [
  '',
  'NotArrived',
  'InProgress',
  'Completed',
  'NoShow',
  'Canceled',
];

const Map<String, String> _statusLabels = {
  '': 'All',
  'NotArrived': 'Not Arrived',
  'InProgress': 'In Progress',
  'Completed': 'Completed',
  'NoShow': 'No Show',
  'Canceled': 'Canceled',
};

Color _statusColor(String status) {
  switch (status) {
    case 'NotArrived':
      return Colors.orange;
    case 'Waiting':
      return Colors.blue;
    case 'InProgress':
      return const Color(0xFF0D7C66);
    case 'Completed':
      return Colors.green;
    case 'NoShow':
      return Colors.red;
    case 'Canceled':
      return Colors.grey;
    default:
      return Colors.grey;
  }
}

class UserAppointmentsPage extends StatefulWidget {
  const UserAppointmentsPage({super.key});

  @override
  State<UserAppointmentsPage> createState() => _UserAppointmentsPageState();
}

class _UserAppointmentsPageState extends State<UserAppointmentsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '';
  String _customerId = '';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadCustomerId();
  }

  Future<void> _loadCustomerId() async {
    final authLocal = sl<AuthLocalDataSource>();
    final user = await authLocal.getCurrentUser();

    String? uid;
    if (user != null && user.id.isNotEmpty) {
      uid = user.id;
    } else {
      uid = await _extractUserIdFromToken(authLocal);
    }

    if (uid != null && uid.isNotEmpty && mounted) {
      final id = uid;
      setState(() => _customerId = id);
      context.read<UserAppointmentsBloc>().add(
            LoadUserAppointments(customerId: id),
          );
    }
  }

  Future<String?> _extractUserIdFromToken(AuthLocalDataSource authLocal) async {
    final token = await authLocal.getUserToken();
    if (token == null || token.isEmpty) return null;
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final json = jsonDecode(payload) as Map<String, dynamic>;
      return (json['sub'] ?? json['nameid'] ?? json['userId'])?.toString();
    } catch (_) {
      return null;
    }
  }

  void _onSearchChanged(String query) {
    context.read<UserAppointmentsBloc>().add(
          FilterUserAppointments(
            searchQuery: query,
            statusFilter: _selectedStatus.isEmpty ? null : _selectedStatus,
            sortAscending: _sortAscending,
          ),
        );
  }

  void _onStatusChanged(String status) {
    setState(() => _selectedStatus = status);
    if (_customerId.isNotEmpty) {
      context.read<UserAppointmentsBloc>().add(
            LoadUserAppointments(
              customerId: _customerId,
              statusFilter: status.isEmpty ? null : status,
            ),
          );
    }
    context.read<UserAppointmentsBloc>().add(
          FilterUserAppointments(
            searchQuery: _searchController.text,
            statusFilter: status.isEmpty ? null : status,
            sortAscending: _sortAscending,
          ),
        );
  }

  void _onSortToggle() {
    setState(() => _sortAscending = !_sortAscending);
    context.read<UserAppointmentsBloc>().add(
          FilterUserAppointments(
            searchQuery: _searchController.text,
            statusFilter: _selectedStatus.isEmpty ? null : _selectedStatus,
            sortAscending: _sortAscending,
          ),
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _primary),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text(
          'My Appointments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        iconTheme: const IconThemeData(color: _primary),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSortRow(),
          _buildStatusFilter(),
          const Divider(height: 1, color: _border),
          Expanded(
            child: BlocBuilder<UserAppointmentsBloc, UserAppointmentsState>(
              builder: (context, state) {
                return switch (state) {
                  UserAppointmentsInitial() ||
                  UserAppointmentsLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  UserAppointmentsError(:final message) =>
                    _buildErrorState(message),
                  UserAppointmentsLoaded(:final filteredAppointments) =>
                    filteredAppointments.isEmpty
                        ? _buildEmptyState()
                        : _buildAppointmentsList(filteredAppointments),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search by branch...',
          hintStyle: const TextStyle(color: _textSecondary),
          prefixIcon: const Icon(Icons.search, color: _primary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: _bg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSortRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            'Sort by date',
            style: const TextStyle(fontSize: 13, color: _textSecondary),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _onSortToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _sortAscending ? 'Oldest first' : 'Newest first',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _sortAscending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 16,
                    color: _primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _statusOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = _statusOptions[index];
          final isSelected = _selectedStatus == status;
          return FilterChip(
            label: Text(_statusLabels[status]!),
            selected: isSelected,
            onSelected: (_) => _onStatusChanged(status),
            selectedColor: _primary.withValues(alpha: 0.15),
            checkmarkColor: _primary,
            labelStyle: TextStyle(
              color: isSelected ? _primary : _textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
            side: BorderSide(
              color: isSelected ? _primary : _border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentsList(List<ReservedAppointment> appointments) {
    return RefreshIndicator(
      onRefresh: () async {
        if (_customerId.isNotEmpty) {
          context.read<UserAppointmentsBloc>().add(
                LoadUserAppointments(
                  customerId: _customerId,
                  statusFilter:
                      _selectedStatus.isEmpty ? null : _selectedStatus,
                ),
              );
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return _AppointmentCard(
            appointment: appointments[index],
            onTap: () => context.push(
              AppRoutes.appointmentDetail,
              extra: appointments[index],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 64, color: _border),
          const SizedBox(height: 16),
          const Text(
            'No appointments found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your booked appointments will appear here',
            style: TextStyle(color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_customerId.isNotEmpty) {
                  context.read<UserAppointmentsBloc>().add(
                        LoadUserAppointments(customerId: _customerId),
                      );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final ReservedAppointment appointment;
  final VoidCallback onTap;

  const _AppointmentCard({
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${appointment.reservationDate.day.toString().padLeft(2, '0')}/'
        '${appointment.reservationDate.month.toString().padLeft(2, '0')}/'
        '${appointment.reservationDate.year}';
    final timeStr =
        '${appointment.reservationDate.hour.toString().padLeft(2, '0')}:'
        '${appointment.reservationDate.minute.toString().padLeft(2, '0')}';
    final isPast = appointment.reservationDate.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - value)),
            child: child,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.calendar_month,
                              color: _primary,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.serviceName ?? 'Service',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.person_outline,
                                      size: 14, color: _textSecondary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      appointment.staffName ?? 'Doctor',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: _textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (appointment.organizationName != null &&
                                  appointment.organizationName!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(
                                    children: [
                                      Icon(Icons.business,
                                          size: 14, color: _textSecondary),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          appointment.organizationName!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: _textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (appointment.branchName != null &&
                                  appointment.branchName!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on_outlined,
                                          size: 14, color: _textSecondary),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          appointment.branchName!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: _textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        _buildStatusBadge(appointment.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: _border),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.calendar_today,
                          dateStr,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          Icons.access_time,
                          timeStr,
                        ),
                        if (appointment.branchName != null &&
                            appointment.branchName!.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoChip(
                              Icons.location_on_outlined,
                              appointment.branchName!,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (isPast && appointment.status == 'NotArrived')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Past appointment - please reschedule if needed',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabels[status] ?? status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _statusColor(status),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _accent),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: _textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
