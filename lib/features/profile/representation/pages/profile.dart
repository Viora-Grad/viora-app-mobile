import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local.dart';
import 'package:viora_app/features/appointments/domain/usecases/get_user_appointments.dart';
import 'package:viora_app/features/profile/domain/entities/user.dart';
import 'package:viora_app/features/profile/domain/repositories/user_repository.dart';

const _fieldNames = ['Username', 'Phone Number'];
const _fieldIcons = [Icons.person, Icons.phone];

const Color _primary = Color(0xFF2F1193);

enum _ProfileStatus { initial, loading, success, failure }

class _ProfileState {
  final _ProfileStatus status;
  final User? user;
  final String? error;
  final String? userName;
  final String? phoneNumber;
  final int showed;
  final int inProgress;
  final int cancelled;

  _ProfileState._({
    required this.status,
    this.user,
    this.error,
    this.userName,
    this.phoneNumber,
    this.showed = 0,
    this.inProgress = 0,
    this.cancelled = 0,
  });

  factory _ProfileState.initial() =>
      _ProfileState._(status: _ProfileStatus.initial);
  factory _ProfileState.loading() =>
      _ProfileState._(status: _ProfileStatus.loading);
  factory _ProfileState.success({
    required User user,
    String? userName,
    String? phoneNumber,
    int showed = 0,
    int inProgress = 0,
    int cancelled = 0,
  }) =>
      _ProfileState._(
        status: _ProfileStatus.success,
        user: user,
        userName: userName,
        phoneNumber: phoneNumber,
        showed: showed,
        inProgress: inProgress,
        cancelled: cancelled,
      );
  factory _ProfileState.failure(String error) =>
      _ProfileState._(status: _ProfileStatus.failure, error: error);
}

class ProfileCubit extends Cubit<_ProfileState> {
  final UserRepository userRepository;
  final AuthLocalDataSource authLocal;
  final GetUserAppointmentsUseCase getUserAppointments;

  ProfileCubit(this.userRepository, this.authLocal, this.getUserAppointments)
      : super(_ProfileState.initial());

  Future<void> loadProfile() async {
    emit(_ProfileState.loading());
    final result = await userRepository.getUserProfile();
    final userName = await authLocal.getUserName();
    final phoneNumber = await authLocal.getPhoneNumber();
    await result.fold(
      (failure) async => emit(_ProfileState.failure(failure.message)),
      (user) async {
        int showed = 0, inProgress = 0, cancelled = 0;
        try {
          final token = await authLocal.getUserToken();
          String? customerId;
          if (token != null && token.isNotEmpty) {
            try {
              final parts = token.split('.');
              if (parts.length >= 2) {
                final payload = utf8.decode(
                  base64Url.decode(base64Url.normalize(parts[1])),
                );
                final json = jsonDecode(payload) as Map<String, dynamic>;
                customerId = (json['sub'] ?? json['nameid'] ?? json['userId'])?.toString();
              }
            } catch (_) {}
          }
          debugPrint('[ProfileCubit] customerId=$customerId');
          if (customerId != null && customerId.isNotEmpty) {
            final appointments = await getUserAppointments(
              customerId: customerId,
            );
            appointments.fold(
              (failure) {
                debugPrint('[ProfileCubit] getUserAppointments failed: ${failure.message}');
              },
              (list) {
                debugPrint('[ProfileCubit] appointments count: ${list.length}');
                for (final a in list) {
                  debugPrint('[ProfileCubit]   id=${a.id} status=${a.status} date=${a.reservationDate}');
                  switch (a.status) {
                    case 'Completed':
                      showed++;
                      break;
                    case 'NotArrived':
                      inProgress++;
                      break;
                    case 'Canceled':
                      cancelled++;
                      break;
                  }
                }
                debugPrint('[ProfileCubit] showed=$showed inProgress=$inProgress cancelled=$cancelled');
              },
            );
          }
        } catch (_) {}
        emit(_ProfileState.success(
          user: user,
          userName: userName,
          phoneNumber: phoneNumber,
          showed: showed,
          inProgress: inProgress,
          cancelled: cancelled,
        ));
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepository = sl<UserRepository>();
    final authLocal = sl<AuthLocalDataSource>();
    final getUserAppointments = sl<GetUserAppointmentsUseCase>();
    return BlocProvider<ProfileCubit>(
      create: (_) => ProfileCubit(userRepository, authLocal, getUserAppointments)..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _logout(BuildContext context) async {
    final authLocal = sl<AuthLocalDataSource>();
    await authLocal.logout();
    if (context.mounted) {
      context.go('/login');
    }
  }

  Widget _skeletonCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _skeletonBox(double width, double height, Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<ProfileCubit, _ProfileState>(
        builder: (context, state) {
          if (state.status == _ProfileStatus.loading ||
              state.status == _ProfileStatus.initial) {
            return _buildSkeleton();
          }

          if (state.status == _ProfileStatus.failure) {
            return Center(
              child: Text('Failed to load profile: ${state.error}'),
            );
          }

          final user = state.user!;
          final initials = user.name
              .split(' ')
              .where((e) => e.isNotEmpty)
              .map((e) => e[0])
              .take(2)
              .join();
          final genderLabel = switch (user.gender) {
            Gender.male => 'Male',
            Gender.female => 'Female',
            _ => '',
          };

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ProfileHeader(
                    initials: initials,
                    name: user.name,
                    email: user.email,
                  ),
                  const SizedBox(height: 20),
                  _AppointmentStats(
                    showed: state.showed,
                    inProgress: state.inProgress,
                    cancelled: state.cancelled,
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard(context, user, genderLabel),
                  const SizedBox(height: 16),
                  if (state.userName != null || state.phoneNumber != null)
                    _buildExtraInfoCard(context, state.userName, state.phoneNumber),
                  const SizedBox(height: 16),
                  _ActionButton(
                    label: 'Logout',
                    icon: Icons.logout,
                    danger: true,
                    onPressed: () => _logout(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, User user, String genderLabel) {
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          if (user.age > 0 || genderLabel.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  if (user.age > 0)
                    Expanded(
                      child: _StatTile(
                        icon: Icons.cake_outlined,
                        label: 'Age',
                        value: '${user.age} years',
                      ),
                    ),
                  if (user.age > 0 && genderLabel.isNotEmpty)
                    const SizedBox(width: 12),
                  if (genderLabel.isNotEmpty)
                    Expanded(
                      child: _StatTile(
                        icon: Icons.person_outline,
                        label: 'Gender',
                        value: genderLabel,
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          _buildGrid([
            _GridItemData(
              icon: Icons.folder_outlined,
              label: 'Medical Record',
              onTap: () async {
                final msg = await context.push<String>('/medical-record');
                if (msg != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg), backgroundColor: const Color(0xFF28F0A8)),
                  );
                }
              },
            ),
            _GridItemData(
              icon: Icons.location_on_outlined,
              label: 'Visited',
              onTap: () => context.push(AppRoutes.myAppointments),
            ),
            _GridItemData(
              icon: Icons.bookmark_outline_rounded,
              label: 'Saved',
              onTap: () => context.push('/saved-organizations'),
            ),
            _GridItemData(
              icon: Icons.lock_outlined,
              label: 'Change Password',
              onTap: () => context.push('/change-password'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildGrid(List<_GridItemData> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 12.0;
        final childWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items.map((item) {
            return SizedBox(
              width: childWidth,
              child: _GridCard(
                icon: item.icon,
                label: item.label,
                onTap: item.onTap,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildExtraInfoCard(
      BuildContext context, String? userName, String? phoneNumber) {
    final values = [userName, phoneNumber];
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < _fieldNames.length; i++)
            if (values[i] != null && values[i]!.isNotEmpty) ...[
              if (i > 0) const Divider(height: 1, indent: 56),
              _InfoTile(
                icon: _fieldIcons[i],
                label: _fieldNames[i],
                value: values[i]!,
              ),
            ],
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    final skeletonColor = Colors.grey.shade200;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _skeletonCircle(88, skeletonColor),
                    const SizedBox(height: 16),
                    _skeletonBox(180, 20, skeletonColor),
                    const SizedBox(height: 8),
                    _skeletonBox(200, 14, skeletonColor),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(child: _skeletonBox(double.infinity, 80, skeletonColor)),
                  const SizedBox(width: 10),
                  Expanded(child: _skeletonBox(double.infinity, 80, skeletonColor)),
                  const SizedBox(width: 10),
                  Expanded(child: _skeletonBox(double.infinity, 80, skeletonColor)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8E8EE)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _skeletonBox(double.infinity, 72, skeletonColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _skeletonBox(double.infinity, 72, skeletonColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(
                      3,
                      (_) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            _skeletonCircle(44, skeletonColor),
                            const SizedBox(width: 16),
                            Expanded(child: _skeletonBox(160, 16, skeletonColor)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _skeletonBox(double.infinity, 56, skeletonColor),
              const SizedBox(height: 12),
              _skeletonBox(double.infinity, 56, skeletonColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.initials,
    required this.name,
    required this.email,
  });

  final String initials;
  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _primary,
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AppointmentStats extends StatelessWidget {
  const _AppointmentStats({
    required this.showed,
    required this.inProgress,
    required this.cancelled,
  });

  final int showed;
  final int inProgress;
  final int cancelled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Showed', value: showed, color: const Color(0xFF28F0A8))),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(label: 'In Progress', value: inProgress, color: const Color(0xFFF5A623))),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(label: 'Cancelled', value: cancelled, color: const Color(0xFFFF6B6B))),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GridItemData {
  const _GridItemData({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _GridCard extends StatelessWidget {
  const _GridCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEEAF7)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _primary, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
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
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.danger = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    if (danger) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFE53935),
            side: const BorderSide(color: Color(0xFFFFCDD2)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
