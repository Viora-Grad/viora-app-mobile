import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/features/profile/domain/repositories/user_repository.dart';

const Color _primary = Color(0xFF2F1193);

enum _ChangePasswordStatus { initial, loading, success, failure }

class _ChangePasswordState {
  final _ChangePasswordStatus status;
  final String? error;

  _ChangePasswordState._({required this.status, this.error});

  factory _ChangePasswordState.initial() =>
      _ChangePasswordState._(status: _ChangePasswordStatus.initial);
  factory _ChangePasswordState.loading() =>
      _ChangePasswordState._(status: _ChangePasswordStatus.loading);
  factory _ChangePasswordState.success() =>
      _ChangePasswordState._(status: _ChangePasswordStatus.success);
  factory _ChangePasswordState.failure(String error) =>
      _ChangePasswordState._(status: _ChangePasswordStatus.failure, error: error);
}

class _ChangePasswordCubit extends Cubit<_ChangePasswordState> {
  final UserRepository userRepository;

  _ChangePasswordCubit(this.userRepository) : super(_ChangePasswordState.initial());

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(_ChangePasswordState.loading());
    final result = await userRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    result.fold(
      (failure) => emit(_ChangePasswordState.failure(failure.message)),
      (_) => emit(_ChangePasswordState.success()),
    );
  }
}

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepository = sl<UserRepository>();
    return BlocProvider<_ChangePasswordCubit>(
      create: (_) => _ChangePasswordCubit(userRepository),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<_ChangePasswordCubit>().changePassword(
            currentPassword: _currentPasswordController.text.trim(),
            newPassword: _newPasswordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<_ChangePasswordCubit, _ChangePasswordState>(
      listener: (context, state) {
        if (state.status == _ChangePasswordStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully'),
              backgroundColor: Color(0xFF28F0A8),
            ),
          );
          context.go('/profile');
        } else if (state.status == _ChangePasswordStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'Failed to change password'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Form(
              key: _formKey,
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
                      const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPasswordField(
                          controller: _currentPasswordController,
                          label: 'Current Password',
                          obscure: _obscureCurrent,
                          onToggle: () =>
                              setState(() => _obscureCurrent = !_obscureCurrent),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Current password is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          label: 'New Password',
                          obscure: _obscureNew,
                          onToggle: () =>
                              setState(() => _obscureNew = !_obscureNew),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'New password is required';
                            }
                            if (value.length < 8) {
                              return 'Must be at least 8 characters';
                            }
                            if (value.length > 100) {
                              return 'Must not exceed 100 characters';
                            }
                            if (!RegExp(r'[A-Z]').hasMatch(value)) {
                              return 'Must contain an uppercase letter';
                            }
                            if (!RegExp(r'[a-z]').hasMatch(value)) {
                              return 'Must contain a lowercase letter';
                            }
                            if (!RegExp(r'[0-9]').hasMatch(value)) {
                              return 'Must contain a number';
                            }
                            if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(value)) {
                              return 'Must contain a special character';
                            }
                            if (value == _currentPasswordController.text) {
                              return 'Must be different from current password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          label: 'Confirm New Password',
                          obscure: _obscureConfirm,
                          onToggle: () =>
                              setState(() => _obscureConfirm = !_obscureConfirm),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your new password';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<_ChangePasswordCubit, _ChangePasswordState>(
                    builder: (context, state) {
                      final isLoading =
                          state.status == _ChangePasswordStatus.loading;
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _primary.withValues(alpha: 0.5),
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
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock_outline, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Update Password',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
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
        prefixIcon: Icon(Icons.lock_outline, color: _primary, size: 22),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey.shade400,
            size: 22,
          ),
          onPressed: onToggle,
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
