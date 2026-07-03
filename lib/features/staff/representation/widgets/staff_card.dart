import 'package:flutter/material.dart';
import 'package:viora_app/features/staff/domain/entities/staff.dart';

const Color _primary = Color(0xFF0D7C66);
const Color _accent = Color(0xFF14A085);
const Color _bg = Color(0xFFF0FCF8);
const Color _border = Color(0xFFC8E6DE);

class StaffCard extends StatelessWidget {
  final Staff staff;
  final int index;

  const StaffCard({
    super.key,
    required this.staff,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 14),
                  Expanded(child: _buildNameAndDetails()),
                  _buildStatusDot(),
                ],
              ),
              if (staff.shifts.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildScheduleSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initials = staff.fullName.isNotEmpty
        ? staff.fullName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join()
        : '?';
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
      ),
    );
  }

  Widget _buildNameAndDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          staff.fullName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (staff.gender.isNotEmpty) ...[
              Icon(Icons.person_outline, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                staff.gender == 'male' ? 'Male' : staff.gender == 'female' ? 'Female' : staff.gender,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
            ],
            if (staff.age != null) ...[
              Icon(Icons.cake_outlined, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                '${staff.age} years',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        if (staff.phoneNumber.isNotEmpty) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 13, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                staff.phoneNumber,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatusDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: staff.shiftsForToday.isNotEmpty ? const Color(0xFF4CAF50) : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 14, color: _accent),
            const SizedBox(width: 6),
            Text(
              'Available Days',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: staff.shifts.map((shift) {
            final isToday = _isDayToday(shift.day);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isToday ? _bg : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isToday ? _accent.withValues(alpha: 0.3) : _border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    shift.day.substring(0, 3),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isToday ? _primary : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${shift.startTime.substring(0, 5)}-${shift.endTime.substring(0, 5)}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isToday ? _accent : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _isDayToday(String day) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final today = days[DateTime.now().weekday - 1];
    return day.toLowerCase() == today.toLowerCase();
  }
}
