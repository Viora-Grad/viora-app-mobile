import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local.dart';
import 'package:viora_app/features/reviews/domain/entities/review.dart';
import 'package:viora_app/features/reviews/representation/bloc/review_bloc.dart';
import 'package:viora_app/features/reviews/representation/bloc/review_event.dart';
import 'package:viora_app/features/reviews/representation/bloc/review_state.dart';
import 'package:viora_app/features/reviews/representation/widgets/feedback_dialog.dart';
import 'package:viora_app/features/reviews/representation/widgets/review_card.dart';

const Color _primary = Color(0xFF0D7C66);
const Color _accent = Color(0xFF14A085);
const Color _bg = Color(0xFFF0FCF8);
const Color _border = Color(0xFFC8E6DE);

class ReviewsSection extends StatefulWidget {
  final String branchId;

  const ReviewsSection({super.key, required this.branchId});

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    context
        .read<ReviewBloc>()
        .add(GetBranchReviews(branchId: widget.branchId));
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final authLocal = sl<AuthLocalDataSource>();
      final token = await authLocal.getUserToken();
      if (token == null || token.isEmpty) return;
      final parts = token.split('.');
      if (parts.length < 2) return;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final json = jsonDecode(payload) as Map<String, dynamic>;
      final uid = (json['sub'] ?? json['nameid'] ?? json['userId'])?.toString();
      debugPrint('[ReviewsSection] uid=$uid');
      if (uid != null && uid.isNotEmpty && mounted) {
        setState(() => _currentUserId = uid);
      }
    } catch (e) {
      debugPrint('[ReviewsSection] token decode failed: $e');
    }
  }

  Future<void> _editFeedback(Review review) async {
    final result = await showFeedbackDialog(
      context,
      widget.branchId,
      existingFeedback: review,
    );
    if (result == true && mounted) {
      context
          .read<ReviewBloc>()
          .add(GetBranchReviews(branchId: widget.branchId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewBloc, ReviewState>(
      key: ValueKey('reviews_$_currentUserId'),
      builder: (context, state) {
        if (state is ReviewLoading) {
          return _buildSectionHeader(null);
        }
        if (state is ReviewError) {
          return const SizedBox.shrink();
        }
        if (state is ReviewLoaded) {
          return _buildContent(state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(ReviewLoaded state) {
    if (state.reviews.isEmpty) return const SizedBox.shrink();

    final reviews = state.reviews;

    List<Review> userReview = [];
    List<Review> otherReviews;
    if (_currentUserId != null) {
      userReview = reviews
          .where((r) => r.userId == _currentUserId)
          .toList();
      otherReviews = reviews
          .where((r) => r.userId != _currentUserId)
          .toList();
    } else {
      otherReviews = List.from(reviews);
    }

    otherReviews
        .sort((a, b) => b.createdAtUtc.compareTo(a.createdAtUtc));
    final latestOthers = otherReviews.take(5).toList();

    final displayList = [...userReview, ...latestOthers];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(state.reviews.length),
          const SizedBox(height: 16),
          _buildAverageRatingCard(state),
          const SizedBox(height: 16),
          _buildRatingBreakdown(state),
          const SizedBox(height: 20),
          ...displayList.map((review) => ReviewCard(
                review: review,
                isOwnReview: review.userId == _currentUserId,
                onEdit: review.userId == _currentUserId
                    ? () => _editFeedback(review)
                    : null,
              )),
          if (state.reviews.length > displayList.length) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                '+${state.reviews.length - displayList.length} more reviews',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(int? count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.star_rounded, size: 18, color: _accent),
        ),
        const SizedBox(width: 10),
        Text(
          'Reviews',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _accent,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAverageRatingCard(ReviewLoaded state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary.withValues(alpha: 0.08), _bg],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '/ 10',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Rating',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(5, (i) {
                      final filled = state.averageRating / 2 > i;
                      final half = !filled &&
                          state.averageRating / 2 > i - 0.5;
                      return Icon(
                        filled
                            ? Icons.star_rounded
                            : half
                                ? Icons.star_half_rounded
                                : Icons.star_outline_rounded,
                        color: const Color(0xFFE88D2F),
                        size: 20,
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Based on ${state.reviews.length} ${state.reviews.length == 1 ? 'review' : 'reviews'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdown(ReviewLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          _buildBreakdownRow(
              'Service', state.averageServiceRating, Icons.medical_services_outlined),
          const SizedBox(height: 10),
          _buildBreakdownRow(
              'Branch', state.averageBranchRating, Icons.business_outlined),
          const SizedBox(height: 10),
          _buildBreakdownRow(
              'System Experience', state.averageSystemExperienceRating,
              Icons.design_services_outlined),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
      String label, double rating, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _accent),
        const SizedBox(width: 8),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rating / 10,
              backgroundColor: _border,
              valueColor: const AlwaysStoppedAnimation<Color>(_accent),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 36,
          child: Text(
            rating.toStringAsFixed(1),
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
