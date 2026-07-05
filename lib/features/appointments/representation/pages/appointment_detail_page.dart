import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/features/appointments/domain/entities/reserved_appointment.dart';
import 'package:viora_app/features/appointments/domain/usecases/cancel_appointment.dart';

const Color _primary = Color(0xFF0D7C66);
const Color _accent = Color(0xFF14A085);
const Color _bg = Color(0xFFF0FCF8);
const Color _border = Color(0xFFC8E6DE);
const Color _textPrimary = Color(0xFF1A1A2E);
const Color _textSecondary = Color(0xFF6B7280);

const Map<String, String> _statusLabels = {
  'NotArrived': 'Not Arrived',
  'Waiting': 'Waiting',
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

class AppointmentDetailPage extends StatefulWidget {
  final ReservedAppointment appointment;

  const AppointmentDetailPage({super.key, required this.appointment});

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  bool _isCancelling = false;

  void _cancelAppointment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment? '
          'The amount will be refunded to your wallet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Appointment'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _isCancelling = true);

    final useCase = sl<CancelAppointmentUseCase>();
    final result = await useCase.call(widget.appointment.id);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isCancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment cancelled successfully. '
                'Amount refunded to your wallet.'),
            backgroundColor: Color(0xFF0D7C66),
          ),
        );
        context.pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${widget.appointment.reservationDate.day.toString().padLeft(2, '0')}/'
        '${widget.appointment.reservationDate.month.toString().padLeft(2, '0')}/'
        '${widget.appointment.reservationDate.year}';
    final timeStr =
        '${widget.appointment.reservationDate.hour.toString().padLeft(2, '0')}:'
        '${widget.appointment.reservationDate.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Appointment Details',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 32),
            _buildQrCode(),
            if (widget.appointment.status == 'Completed') ...[
              const SizedBox(height: 20),
              _buildPrescriptionButton(context),
            ],
            if (widget.appointment.status == 'NotArrived') ...[
              const SizedBox(height: 20),
              _buildCancelButton(),
            ],
            const SizedBox(height: 32),
            _buildInstructions(),
            const SizedBox(height: 32),
            _buildSummaryCard(dateStr, timeStr),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: _statusColor(widget.appointment.status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _statusIcon(widget.appointment.status),
            color: _statusColor(widget.appointment.status),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _statusLabels[widget.appointment.status] ?? widget.appointment.status,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _statusColor(widget.appointment.status),
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'NotArrived':
        return Icons.schedule;
      case 'Waiting':
        return Icons.hourglass_top;
      case 'InProgress':
        return Icons.emergency;
      case 'Completed':
        return Icons.check_circle;
      case 'NoShow':
        return Icons.cancel;
      case 'Canceled':
        return Icons.block;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildQrCode() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Appointment QR Code',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Show this to the receptionist',
            style: TextStyle(
              fontSize: 13,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: QrImageView(
              data: widget.appointment.id,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: _primary,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: _textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fingerprint, size: 14, color: _accent),
                const SizedBox(width: 6),
                Text(
                  'ID: ${widget.appointment.id.substring(0, 8).toUpperCase()}...',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: _primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'How to use this QR Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStep(1, 'Arrive at the branch before your appointment time.'),
          const SizedBox(height: 12),
          _buildStep(2,
              'Show this QR code to the receptionist at the front desk.'),
          const SizedBox(height: 12),
          _buildStep(
            3,
            'The receptionist will scan the code to confirm your arrival and start the service.',
          ),
          const SizedBox(height: 12),
          _buildStep(
            4,
            'Wait for your turn. You will be notified when the doctor is ready.',
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: _primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: _textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrescriptionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.push(
          AppRoutes.prescription,
          extra: widget.appointment.id,
        ),
        icon: const Icon(Icons.medication),
        label: const Text(
          'View Prescription',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isCancelling ? null : _cancelAppointment,
        icon: _isCancelling
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.cancel_outlined),
        label: Text(
          _isCancelling ? 'Cancelling...' : 'Cancel Appointment',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE53935),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String dateStr, String timeStr) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: _primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Appointment Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(Icons.calendar_today, 'Date', dateStr),
          const Divider(height: 20, color: _border),
          _buildSummaryRow(Icons.access_time, 'Time', timeStr),
          const Divider(height: 20, color: _border),
          _buildSummaryRow(Icons.medical_services_outlined, 'Service',
              widget.appointment.serviceName ?? 'N/A'),
          const Divider(height: 20, color: _border),
          _buildSummaryRow(Icons.person_outline, 'Doctor',
              widget.appointment.staffName ?? 'N/A'),
          const Divider(height: 20, color: _border),
          _buildSummaryRow(Icons.business, 'Organization',
              widget.appointment.organizationName ?? 'N/A'),
          const Divider(height: 20, color: _border),
          _buildSummaryRow(Icons.location_on_outlined, 'Branch',
              widget.appointment.branchName ?? 'N/A'),
          if (widget.appointment.cost != null && widget.appointment.cost!.isNotEmpty) ...[
            const Divider(height: 20, color: _border),
            _buildSummaryRow(
                Icons.attach_money, 'Cost', '\$${widget.appointment.cost}'),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _accent),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: _textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }
}
