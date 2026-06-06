import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum _ProfileStatus { initial, loading, success, failure }

class Profile {
  final String name;
  final String email;
  final int age;
  final int weightKg;
  final int heightCm;
  final String? avatarUrl;

  Profile({
    required this.name,
    required this.email,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    this.avatarUrl,
  });
}

class _ProfileState {
  final _ProfileStatus status;
  final Profile? profile;
  final String? error;

  _ProfileState._({required this.status, this.profile, this.error});

  factory _ProfileState.initial() =>
      _ProfileState._(status: _ProfileStatus.initial);
  factory _ProfileState.loading() =>
      _ProfileState._(status: _ProfileStatus.loading);
  factory _ProfileState.success(Profile profile) =>
      _ProfileState._(status: _ProfileStatus.success, profile: profile);
  factory _ProfileState.failure(String error) =>
      _ProfileState._(status: _ProfileStatus.failure, error: error);
}

class ProfileCubit extends Cubit<_ProfileState> {
  final Future<Profile> Function()? fetchProfile;

  ProfileCubit({this.fetchProfile}) : super(_ProfileState.initial());

  Future<void> loadProfile() async {
    emit(_ProfileState.loading());
    try {
      if (fetchProfile != null) {
        final p = await fetchProfile!();
        emit(_ProfileState.success(p));
      } else {
        // Fallback: simulate a network fetch. Replace with real repository call.
        await Future.delayed(const Duration(milliseconds: 900));
        final p = Profile(
          name: 'Sarah Jenkins',
          email: 'sarah.jenkins@viorahealth.com',
          age: 28,
          weightKg: 62,
          heightCm: 170,
          avatarUrl: null,
        );
        emit(_ProfileState.success(p));
      }
    } catch (e) {
      emit(_ProfileState.failure(e.toString()));
    }
  }
}

/// ProfilePage: presents the profile UI and shows a skeleton while loading.
///
/// Notes:
/// - This file provides a self-contained `ProfileCubit` for the page so it
///   compiles standalone. In the app, prefer injecting a feature-level BLoC
///   / Cubit that uses the domain/repository layers.
class ProfilePage extends StatelessWidget {
  final ProfileCubit? cubit;

  const ProfilePage({Key? key, this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => cubit ?? ProfileCubit()
        ..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({Key? key}) : super(key: key);

  Widget _skeletonCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _skeletonBox({
    double height = 16,
    double width = 80,
    BorderRadius? radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: radius ?? BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black87),
        title: const Text('Profile', style: TextStyle(color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit, color: Colors.black54),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, _ProfileState>(
          builder: (context, state) {
            if (state.status == _ProfileStatus.loading ||
                state.status == _ProfileStatus.initial) {
              // Skeleton layout
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    Center(child: _skeletonCircle(96)),
                    const SizedBox(height: 16),
                    _skeletonBox(width: 180, height: 24),
                    const SizedBox(height: 8),
                    _skeletonBox(width: 240, height: 16),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        3,
                        (_) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                            ),
                            child: Container(
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _skeletonBox(width: 48, height: 14),
                                  const SizedBox(height: 8),
                                  _skeletonBox(width: 36, height: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: List.generate(
                        3,
                        (_) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state.status == _ProfileStatus.failure) {
              return Center(
                child: Text('Failed to load profile: ${state.error}'),
              );
            }

            final profile = state.profile!;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: profile.avatarUrl != null
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    child: profile.avatarUrl == null
                        ? Text(
                            profile.name
                                .split(' ')
                                .map((e) => e[0])
                                .take(2)
                                .join(),
                            style: const TextStyle(fontSize: 24),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _InfoCard(title: 'AGE', value: '${profile.age}'),
                      const SizedBox(width: 8),
                      _InfoCard(
                        title: 'WEIGHT',
                        value: '${profile.weightKg}kg',
                      ),
                      const SizedBox(width: 8),
                      _InfoCard(
                        title: 'HEIGHT',
                        value: '${profile.heightCm}cm',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Action list (these should be extracted into small reusable widgets)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: _IconCircle(icon: Icons.folder),
                          title: const Text(
                            'Medical Record',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: _IconCircle(icon: Icons.location_on),
                          title: const Text(
                            'Visited Organizations History',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: _IconCircle(icon: Icons.lock),
                          title: const Text(
                            'Change Password',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({Key? key, required this.title, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;

  const _IconCircle({Key? key, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.purple, size: 20),
    );
  }
}
