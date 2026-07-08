import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/features/Auth/data/datasources/remote/auth_remote.dart';
import 'package:viora_app/features/Auth/representation/blocs/forgot_password_cubit.dart';
import 'package:viora_app/features/Auth/representation/widgets/touched_form_field.dart';

const Color _primary = Color(0xFF2F1193);

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authRemote = sl<AuthRemoteDataSource>();
    return BlocProvider<ForgotPasswordCubit>(
      create: (_) => ForgotPasswordCubit(authRemote),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSendOtp(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ForgotPasswordCubit>().sendOtp(
        _emailController.text.trim(),
      );
    }
  }

  void _onConfirmReset(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final cubitState = context.read<ForgotPasswordCubit>().state;
      context.read<ForgotPasswordCubit>().confirmReset(
        email: cubitState.email,
        otp: _otpController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state.status == ForgotPasswordStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset successfully'),
              backgroundColor: Color(0xFF28F0A8),
            ),
          );
          context.go('/login');
        } else if (state.status == ForgotPasswordStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
          context.read<ForgotPasswordCubit>().resetError();
        }
      },
      builder: (context, state) {
        final isOtpStep = state.step == ForgotPasswordStep.otp;
        final isLoading = state.status == ForgotPasswordStatus.loading;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isOtpStep ? 'Reset Password' : 'Forgot Password',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isOtpStep
                          ? 'Enter the OTP sent to your email and set a new password'
                          : 'Enter your email to receive a password reset OTP',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8E8EE)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TouchedFormField(
                            controller: _emailController,
                            label: 'Email',
                            enabled: !isLoading && !isOtpStep,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: isOtpStep
                                ? TextInputAction.next
                                : TextInputAction.done,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                            validator: (value) {
                              final trimmed = value?.trim() ?? '';
                              if (trimmed.isEmpty) return 'Email is required';
                              final emailRegex =
                                  RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
                              if (!emailRegex.hasMatch(trimmed)) {
                                return 'Invalid email';
                              }
                              return null;
                            },
                          ),
                          if (isOtpStep) ...[
                            const SizedBox(height: 16),
                            TouchedFormField(
                              controller: _otpController,
                              label: 'OTP Code',
                              enabled: !isLoading,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                              ),
                              validator: (value) {
                                final trimmed = value?.trim() ?? '';
                                if (trimmed.isEmpty) return 'OTP is required';
                                if (trimmed.length != 6 ||
                                    !RegExp(r'^\d{6}$').hasMatch(trimmed)) {
                                  return 'Enter a valid 6-digit OTP';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildPasswordField(
                              controller: _newPasswordController,
                              label: 'New Password',
                              obscure: _obscureNew,
                              enabled: !isLoading,
                              onToggle: () =>
                                  setState(() => _obscureNew = !_obscureNew),
                              validator: (value) {
                                final trimmed = value?.trim() ?? '';
                                if (trimmed.isEmpty) {
                                  return 'Password is required';
                                }
                                if (trimmed.length < 8) {
                                  return 'Min 8 characters';
                                }
                                if (trimmed.length > 100) {
                                  return 'Max 100 characters';
                                }
                                if (!RegExp(r'[a-z]').hasMatch(trimmed)) {
                                  return 'Need a lowercase letter';
                                }
                                if (!RegExp(r'[A-Z]').hasMatch(trimmed)) {
                                  return 'Need an uppercase letter';
                                }
                                if (!RegExp(r'[0-9]').hasMatch(trimmed)) {
                                  return 'Need a number';
                                }
                                if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(trimmed)) {
                                  return 'Need a special character';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              obscure: _obscureConfirm,
                              enabled: !isLoading,
                              onToggle: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _newPasswordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => isOtpStep
                                ? _onConfirmReset(context)
                                : _onSendOtp(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              _primary.withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isOtpStep ? 'Reset Password' : 'Send OTP',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required bool enabled,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        prefixIcon: const Icon(Icons.lock_outline, color: _primary, size: 22),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey.shade400,
            size: 22,
          ),
          onPressed: enabled ? onToggle : null,
        ),
        filled: true,
        fillColor: const Color(0xFFF8F8FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8E8EE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8E8EE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
