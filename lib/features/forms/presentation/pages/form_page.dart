import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/features/forms/domain/entities/form_entity.dart';
import 'package:viora_app/features/forms/presentation/bloc/form_bloc.dart';
import 'package:viora_app/features/forms/presentation/bloc/form_event.dart';
import 'package:viora_app/features/forms/presentation/bloc/form_state.dart';
import 'package:viora_app/features/forms/presentation/widgets/question_widgets.dart';

const Color _primary = Color(0xFF0D7C66);
const Color _accent = Color(0xFF14A085);
const Color _surface = Color(0xFFF7FFFD);
const Color _border = Color(0xFFC8E6DE);
const Color _textPrimary = Color(0xFF1A1A2E);
const Color _textSecondary = Color(0xFF6B7280);
const Color _error = Color(0xFFEF4444);

class FormPage extends StatefulWidget {
  final String serviceId;
  final String staffId;
  final String staffName;
  final String serviceName;
  final String branchId;
  final int serviceDurationMinutes;
  final double serviceCost;
  final DateTime reservationDate;
  final String paymentMethod;

  const FormPage({
    super.key,
    required this.serviceId,
    required this.staffId,
    required this.staffName,
    required this.serviceName,
    required this.branchId,
    required this.serviceDurationMinutes,
    required this.serviceCost,
    required this.reservationDate,
    required this.paymentMethod,
  });

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  @override
  void initState() {
    super.initState();
    context.read<FormBloc>().add(LoadForm(serviceId: widget.serviceId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FormBloc, FormLoadState>(
      listener: (context, state) {
        if (state is FormSubmissionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Form submitted & appointment booked!',
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
          context.go(AppRoutes.home);
        }
        if (state is FormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: _error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _surface,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: BlocBuilder<FormBloc, FormLoadState>(
                  builder: (context, state) {
                    if (state is FormLoading) {
                      return _buildLoading();
                    }
                    if (state is FormError) {
                      return _buildError(state.message);
                    }
                    if (state is FormLoaded) {
                      return _buildForm(state);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              _buildBottomBar(),
            ],
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
          Expanded(
            child: Text(
              'Fill Medical Form',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: _primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading form...',
            style: TextStyle(
              fontSize: 15,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  size: 40, color: _error),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load form',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: _textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.read<FormBloc>()
                  .add(LoadForm(serviceId: widget.serviceId)),
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

  Widget _buildForm(FormLoaded state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormHeader(state.form),
          const SizedBox(height: 24),
          ...List.generate(state.form.questions.length, (index) {
            final field = state.form.questions[index];
            return Padding(
              padding: EdgeInsets.only(top: index > 0 ? 20 : 0),
              child: QuestionWidget(
                field: field,
                value: state.answers[field.id] ?? '',
                error: state.errors[field.id],
                hasFile: state.files.containsKey(field.id),
                fileName: state.files[field.id]?.fileName,
                onChanged: (val) => context.read<FormBloc>()
                    .add(UpdateAnswer(questionId: field.id, value: val)),
                onPickFile: field.type == 'file'
                    ? () => _pickFileForQuestion(field.id)
                    : null,
                onRemoveFile: field.type == 'file'
                    ? () => context.read<FormBloc>()
                        .add(RemoveFile(questionId: field.id))
                    : null,
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFormHeader(FormEntity form) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary.withValues(alpha: 0.08), _accent.withValues(alpha: 0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assignment_rounded, size: 24, color: _primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  form.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.staffName}  ·  ${widget.serviceName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '\$${widget.serviceCost.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFileForQuestion(String questionId) async {
    final result = await pickFormFile();
    if (result != null) {
      if (mounted) {
        context.read<FormBloc>().add(PickFile(
              questionId: questionId,
              filePath: result.key,
              fileName: result.value,
            ));
      }
    }
  }

  Widget _buildBottomBar() {
    return BlocBuilder<FormBloc, FormLoadState>(
      builder: (context, state) {
        final isSubmitting = state is FormSubmitting;
        final isLoaded = state is FormLoaded;

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
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: (isLoaded && !isSubmitting)
                      ? () => _submitForm()
                      : null,
                  icon: isSubmitting
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
                    isSubmitting
                        ? 'Submitting...'
                        : 'Submit & Book Appointment',
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
                    elevation: 4,
                    shadowColor: _primary.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitForm() {
    context.read<FormBloc>().add(SubmitFormAndBook(
          serviceId: widget.serviceId,
          staffId: widget.staffId,
          branchId: widget.branchId,
          reservationDate: widget.reservationDate,
          durationMinutes: widget.serviceDurationMinutes,
          paymentMethod: widget.paymentMethod,
        ));
  }
}
