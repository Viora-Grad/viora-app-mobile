import 'package:flutter/material.dart';
import 'package:viora_app/features/appointments/domain/entities/available_slot.dart';

const Color _primary = Color(0xFF0D7C66);
const Color _accent = Color(0xFF14A085);
const Color _border = Color(0xFFC8E6DE);
const Color _textPrimary = Color(0xFF1A1A2E);
const Color _textSecondary = Color(0xFF6B7280);

class TimeSlotGrid extends StatelessWidget {
  final List<AvailableSlot> slots;
  final AvailableSlot? selectedSlot;
  final ValueChanged<AvailableSlot>? onSlotSelected;

  const TimeSlotGrid({
    super.key,
    required this.slots,
    this.selectedSlot,
    this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.event_busy_rounded,
                    size: 40, color: Color(0xFFF97316)),
              ),
              const SizedBox(height: 16),
              Text(
                'No available slots',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'This day is fully booked.\nTry selecting a different date.',
                style: TextStyle(
                  fontSize: 13,
                  color: _textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(Icons.event_available_rounded,
                    size: 16, color: _primary),
                const SizedBox(width: 6),
                Text(
                  '${slots.length} slot${slots.length != 1 ? 's' : ''} available',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: slots.map((slot) {
              final isSelected = selectedSlot == slot;
              return GestureDetector(
                onTap: () => onSlotSelected?.call(slot),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? _primary : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? _primary : _border,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _primary.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: isSelected ? Colors.white : _accent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${slot.formattedStart} - ${slot.formattedEnd}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : _textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
