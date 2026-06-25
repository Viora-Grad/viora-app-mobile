import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local.dart';
import 'package:viora_app/features/profile/domain/entities/user.dart';
import 'package:viora_app/features/profile/domain/repositories/user_repository.dart';

const Color _violetBg = Color(0xFF240D37);
const Color _violetBgEnd = Color(0xFF1B0B2A);
const Color _gradientStart = Color(0xFF00D5FF);
const Color _gradientEnd = Color(0xFF28F0A8);

enum _ProfileStatus { initial, loading, success, failure }

class _ProfileState {
  final _ProfileStatus status;
  final User? user;
  final String? error;

  _ProfileState._({required this.status, this.user, this.error});

  factory _ProfileState.initial() =>
      _ProfileState._(status: _ProfileStatus.initial);
  factory _ProfileState.loading() =>
      _ProfileState._(status: _ProfileStatus.loading);
  factory _ProfileState.success(User user) =>
      _ProfileState._(status: _ProfileStatus.success, user: user);
  factory _ProfileState.failure(String error) =>
      _ProfileState._(status: _ProfileStatus.failure, error: error);
}

class ProfileCubit extends Cubit<_ProfileState> {
  final UserRepository userRepository;

  ProfileCubit(this.userRepository) : super(_ProfileState.initial());

  Future<void> loadProfile() async {
    emit(_ProfileState.loading());
    final result = await userRepository.getUserProfile();
    result.fold(
      (failure) => emit(_ProfileState.failure(failure.message)),
      (user) => emit(_ProfileState.success(user)),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepository = sl<UserRepository>();
    return BlocProvider<ProfileCubit>(
      create: (_) => ProfileCubit(userRepository)..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({super.key});

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
    final theme = Theme.of(context);

    return Scaffold(
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

          return Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _violetBg,
                          _violetBg.withValues(alpha: 0.97),
                          _violetBgEnd,
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      children: [
                        _ProfileHeader(
                          initials: initials,
                          name: user.name,
                          email: user.email,
                        ),
                        const SizedBox(height: 16),
                        _AppointmentStats(
                          showed: 0,
                          noShow: 0,
                          cancelled: 0,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.05,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.20),
                                blurRadius: 22,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (user.age > 0 || genderLabel.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
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
                              _ActionTile(
                                icon: Icons.folder_outlined,
                                label: 'Medical Record',
                                onTap: () {},
                              ),
                              const Divider(height: 1, indent: 56),
                              _ActionTile(
                                icon: Icons.location_on_outlined,
                                label: 'Visited Organizations History',
                                onTap: () {},
                              ),
                              const Divider(height: 1, indent: 56),
                              _ActionTile(
                                icon: Icons.lock_outlined,
                                label: 'Change Password',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ActionButton(
                          label: 'Edit Profile',
                          icon: Icons.edit_outlined,
                          onPressed: () => context.push('/edit-profile', extra: user),
                        ),
                        const SizedBox(height: 8),
                        _ActionButton(
                          label: 'Logout',
                          icon: Icons.logout,
                          danger: true,
                          onPressed: () => _logout(context),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    final skeletonColor = Colors.white.withValues(alpha: 0.12);
    final cardSkeleton = Colors.white.withValues(alpha: 0.08);

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _violetBg,
                  _violetBg.withValues(alpha: 0.97),
                  _violetBgEnd,
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _skeletonCircle(80, skeletonColor),
                      const SizedBox(height: 16),
                      _skeletonBox(180, 20, skeletonColor),
                      const SizedBox(height: 8),
                      _skeletonBox(200, 14, skeletonColor),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 72,
                              decoration: BoxDecoration(
                                color: cardSkeleton,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 72,
                              decoration: BoxDecoration(
                                color: cardSkeleton,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
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
                              _skeletonCircle(44, cardSkeleton),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _skeletonBox(160, 16, cardSkeleton),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
            gradient: LinearGradient(
              colors: [_gradientStart, _gradientEnd],
            ),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: _violetBg,
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
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
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
    required this.noShow,
    required this.cancelled,
  });

  final int showed;
  final int noShow;
  final int cancelled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Showed', value: showed, color: const Color(0xFF28F0A8))),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(label: 'No Show', value: noShow, color: const Color(0xFFF5A623))),
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
            color: color.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA39AB8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
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
        color: const Color(0xFF240D37).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF240D37)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFA39AB8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF240D37),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF240D37).withValues(alpha: 0.06),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF240D37), size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Color(0xFF240D37),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.black.withValues(alpha: 0.2),
      ),
      onTap: onTap,
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
    final Color bg = danger ? const Color(0xFFFFF0F0) : Colors.white;
    final Color fg = danger ? const Color(0xFFE53935) : _violetBg;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: danger
                ? const Color(0xFFFFCDD2)
                : _violetBg.withValues(alpha: 0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: fg, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
