import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:viora_app/features/service/domain/entities/service.dart';

const Color _primary = Color(0xFF0D7C66);
const Color _accent = Color(0xFF14A085);
const Color _bg = Color(0xFFF0FCF8);
const Color _border = Color(0xFFC8E6DE);

const _serviceIcons = {
  'Cardiology': Icons.favorite,
  'Dentistry': Icons.cleaning_services,
  'Dermatology': Icons.spa,
  'Psychiatry': Icons.psychology,
  'Neurology': Icons.psychology,
  'Ophthalmology': Icons.visibility,
  'Pediatrics': Icons.child_care,
  'Gynecology': Icons.female,
  'Urology': Icons.water_drop,
  'Gastroenterology': Icons.restaurant,
  'Pulmonology': Icons.air,
  'Endocrinology': Icons.monitor_heart,
  'Rheumatology': Icons.accessible,
  'Oncology': Icons.medical_services,
  'Radiology': Icons.image,
  'Anesthesiology': Icons.bedtime,
  'Orthopedics': Icons.biotech,
};

class ServiceCard extends StatelessWidget {
  final Service service;
  final int index;
  final String branchId;
  final VoidCallback? onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.index,
    this.branchId = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getServiceColor(index);
    final icon = _findServiceIcon(service.serviceType);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 200 + (index * 60).clamp(0, 400)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIconContainer(color, icon),
                  const SizedBox(width: 14),
                  Expanded(child: _buildContent(color)),
                  if (service.hasActiveDiscount) _buildDiscountBadge(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(Color color, IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildContent(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          service.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          service.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildInfoChip(
              Icons.access_time_rounded,
              '${service.durationMinutes} min',
            ),
            const SizedBox(width: 8),
            _buildPriceChip(color),
            if (service.status.toLowerCase() != 'active') ...[
              const SizedBox(width: 8),
              _buildStatusBadge(),
            ],
          ],
        ),
      ],
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChip(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (service.hasActiveDiscount) ...[
            Text(
              '${service.currency} ${service.cost.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            '${service.currency} ${service.hasActiveDiscount ? service.discountedCost.toStringAsFixed(0) : service.cost.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: service.hasActiveDiscount ? const Color(0xFFE88D2F) : color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE88D2F).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '-${service.discountPercentage}%',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE88D2F),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        service.status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.red.shade600,
        ),
      ),
    );
  }

  Color _getServiceColor(int index) {
    const colors = [
      Color(0xFF0D7C66),
      Color(0xFFE88D2F),
      Color(0xFF4A6FA5),
      Color(0xFFC0392B),
      Color(0xFF8E44AD),
      Color(0xFF1ABC9C),
      Color(0xFFE67E22),
      Color(0xFF2C3E50),
      Color(0xFFD35400),
    ];
    return colors[index % colors.length];
  }

  IconData _findServiceIcon(String serviceType) {
    for (final entry in _serviceIcons.entries) {
      if (serviceType.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return Icons.medical_services_outlined;
  }

  
}

class _ServiceDetailSheet extends StatelessWidget {
  final Service service;

  const _ServiceDetailSheet({required this.service});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                service.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  service.serviceType,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _accent,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                service.description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                Icons.access_time_rounded,
                'Duration',
                '${service.durationMinutes} minutes',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.attach_money_rounded,
                'Price',
                service.hasActiveDiscount
                    ? '${service.currency} ${service.discountedCost.toStringAsFixed(2)}  (${service.discountPercentage}% off)'
                    : '${service.currency} ${service.cost.toStringAsFixed(2)}',
              ),
              if (service.hasActiveDiscount &&
                  service.discountReason != null &&
                  service.discountReason!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.local_offer_rounded,
                  'Promotion',
                  service.discountReason!,
                ),
              ],
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.info_outline_rounded,
                'Status',
                service.status,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: _accent),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
