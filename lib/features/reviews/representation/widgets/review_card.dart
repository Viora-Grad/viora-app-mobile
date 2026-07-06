import 'package:flutter/material.dart';
import 'package:viora_app/features/reviews/domain/entities/review.dart';

const Color _primary = Color(0xFF0D7C66);
const Color _accent = Color(0xFF14A085);
const Color _bg = Color(0xFFF0FCF8);
const Color _border = Color(0xFFC8E6DE);

class ReviewCard extends StatelessWidget {
  final Review review;
  final bool isOwnReview;
  final VoidCallback? onEdit;

  const ReviewCard({
    super.key,
    required this.review,
    this.isOwnReview = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${review.createdAtUtc.day.toString().padLeft(2, '0')}/'
        '${review.createdAtUtc.month.toString().padLeft(2, '0')}/'
        '${review.createdAtUtc.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _bg,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildRatingBadge(review.totalRatingOutOfTen),
              if (isOwnReview) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: _primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDetailRating('Service', review.serviceRatingOutOfTen),
              const SizedBox(width: 12),
              _buildDetailRating('Branch', review.branchOutOfTen),
              const SizedBox(width: 12),
              _buildDetailRating(
                  'System', review.systemExperienceOutOfTen),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                review.comment!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingBadge(int rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 16, color: _accent),
          const SizedBox(width: 3),
          Text(
            '$rating',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRating(String label, int rating) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '$rating',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
