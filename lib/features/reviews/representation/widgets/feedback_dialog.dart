import 'package:flutter/material.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/features/reviews/domain/entities/review.dart';
import 'package:viora_app/features/reviews/domain/repositories/review_repository.dart';
import 'package:viora_app/features/reviews/domain/usecases/submit_feedback_usecase.dart';
import 'package:viora_app/features/reviews/domain/usecases/update_feedback_usecase.dart';

const Color _primary = Color(0xFF2F1193);
const Color _textPrimary = Color(0xFF111827);
const Color _textSecondary = Color(0xFF6B7280);

Future<bool?> showFeedbackDialog(
  BuildContext context,
  String branchId, {
  Review? existingFeedback,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (ctx) => _FeedbackDialogContent(
      branchId: branchId,
      existingFeedback: existingFeedback,
    ),
  );
}

class _FeedbackDialogContent extends StatefulWidget {
  final String branchId;
  final Review? existingFeedback;

  const _FeedbackDialogContent({
    required this.branchId,
    this.existingFeedback,
  });

  @override
  State<_FeedbackDialogContent> createState() =>
      _FeedbackDialogContentState();
}

class _FeedbackDialogContentState extends State<_FeedbackDialogContent> {
  int _serviceRating = 0;
  int _branchRating = 0;
  int _systemRating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  bool get _isEditing => widget.existingFeedback != null;

  bool get _canSubmit =>
      _serviceRating > 0 && _branchRating > 0 && _systemRating > 0;

  @override
  void initState() {
    super.initState();
    if (widget.existingFeedback != null) {
      final fb = widget.existingFeedback!;
      _serviceRating = fb.serviceRatingOutOfTen;
      _branchRating = fb.branchOutOfTen;
      _systemRating = fb.systemExperienceOutOfTen;
      _commentController.text = fb.comment ?? '';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);

    final params = FeedbackParams(
      feedbackId: widget.existingFeedback?.feedbackId,
      branchId: widget.branchId,
      serviceRatingOutOfTen: _serviceRating,
      branchOutOfTen: _branchRating,
      systemExperienceOutOfTen: _systemRating,
      comment: _commentController.text.isNotEmpty
          ? _commentController.text
          : null,
    );

    final result = _isEditing
        ? await sl<UpdateFeedbackUseCase>()(params)
        : await sl<SubmitFeedbackUseCase>()(params);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_isEditing ? 'Update' : 'Submit'} failed: ${failure.message}'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      },
      (_) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Feedback updated successfully!'
                : 'Thank you for your feedback!'),
            backgroundColor: _primary,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop();
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRatingSection(
                        'Service Quality',
                        _serviceRating,
                        (v) => setState(() => _serviceRating = v),
                      ),
                      const SizedBox(height: 24),
                      _buildRatingSection(
                        'Branch Experience',
                        _branchRating,
                        (v) => setState(() => _branchRating = v),
                      ),
                      const SizedBox(height: 24),
                      _buildRatingSection(
                        'System Experience',
                        _systemRating,
                        (v) => setState(() => _systemRating = v),
                      ),
                      const SizedBox(height: 24),
                      _buildCommentField(),
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Your Feedback' : 'Rate Your Experience',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditing ? 'Update your ratings and comments' : 'Help us improve our service',
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close_rounded,
                  size: 22, color: Color(0xFF9CA3AF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(
    String label,
    int value,
    ValueChanged<int> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              value > 0 ? '$value / 10' : '',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(10, (index) {
            final rating = index + 1;
            final selected = rating <= value;
            return GestureDetector(
              onTap: () => onChanged(rating),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 30,
                height: 32,
                decoration: BoxDecoration(
                  color: selected ? _primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: selected ? _primary : const Color(0xFFD1D5DB),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$rating',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Poor',
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade400)),
            Text('Excellent',
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade400)),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _commentController,
          maxLines: 3,
          maxLength: 500,
          style: const TextStyle(fontSize: 14, color: _textPrimary),
          decoration: InputDecoration(
            hintText: 'Share your experience (optional)',
            hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: _primary, width: 1.5),
            ),
            counterStyle:
                TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _canSubmit && !_isSubmitting ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: const Color(0xFFD1D5DB),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                  _isEditing ? 'Update Feedback' : 'Submit Feedback',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}
