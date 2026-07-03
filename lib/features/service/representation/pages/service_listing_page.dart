import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/features/service/representation/bloc/service_bloc.dart';
import 'package:viora_app/features/service/representation/bloc/service_event.dart';
import 'package:viora_app/features/service/representation/bloc/service_state.dart';
import 'package:viora_app/features/service/representation/widgets/service_card.dart';

const Color _primary = Color(0xFF0D7C66);
const Color _accent = Color(0xFF14A085);
const Color _bg = Color(0xFFF0FCF8);
const Color _border = Color(0xFFC8E6DE);
const Color _surface = Color(0xFFF7FFFD);

const _serviceTypeIcons = {
  'Cardiology': Icons.favorite,
  'Dentistry': Icons.cleaning_services,
  'Dermatology': Icons.spa,
  'Psychiatry': Icons.psychology,
  'Neurology': Icons.psychology,
  'Ophthalmology': Icons.visibility,
  'Pediatrics': Icons.child_care,
  'Gynecology': Icons.female,
  'Urology': Icons.water_drop,
  'Gastroenterology': Icons.restaurant,
  'Pulmonology': Icons.air,
  'Endocrinology': Icons.monitor_heart,
  'Rheumatology': Icons.accessible,
  'Oncology': Icons.medical_services,
  'Radiology': Icons.image,
  'Anesthesiology': Icons.bedtime,
  'Orthopedics': Icons.biotech,
};

class ServiceListingPage extends StatefulWidget {
  final String branchId;
  final String serviceType;

  const ServiceListingPage({
    super.key,
    required this.branchId,
    required this.serviceType,
  });

  @override
  State<ServiceListingPage> createState() => _ServiceListingPageState();
}

class _ServiceListingPageState extends State<ServiceListingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ServiceBloc>()
        ..add(LoadServices(
          branchId: widget.branchId,
          serviceType: widget.serviceType,
        )),
      child: Scaffold(
        backgroundColor: _surface,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildSearchBar(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final icon = _serviceTypeIcons[widget.serviceType] ??
        Icons.medical_services_outlined;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 18, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.serviceType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                BlocBuilder<ServiceBloc, ServiceState>(
                  builder: (context, state) {
                    if (state is ServiceLoaded) {
                      return Text(
                        '${state.filteredServices.length} service${state.filteredServices.length != 1 ? 's' : ''} available',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (value) {
            context.read<ServiceBloc>().add(SearchServices(query: value));
          },
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: 'Search services...',
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.grey.shade400,
              size: 22,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      context
                          .read<ServiceBloc>()
                          .add(const SearchServices(query: ''));
                      _searchFocusNode.unfocus();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ServiceBloc, ServiceState>(
      builder: (context, state) {
        if (state is ServiceLoading) {
          return _buildLoading();
        }
        if (state is ServiceError) {
          return _buildError(state.message);
        }
        if (state is ServiceLoaded) {
          return _buildServiceList(state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _primary),
          const SizedBox(height: 20),
          Text(
            'Loading services...',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Text(
              'Could not load services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.read<ServiceBloc>().add(LoadServices(
                      branchId: widget.branchId,
                      serviceType: widget.serviceType,
                    ));
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceList(ServiceLoaded state) {
    if (state.filteredServices.isEmpty) {
      return _buildEmptyState(state.searchQuery);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: state.filteredServices.length,
      itemBuilder: (context, index) {
        return ServiceCard(
          service: state.filteredServices[index],
          index: index,
        );
      },
    );
  }

  Widget _buildEmptyState(String searchQuery) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              searchQuery.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.medical_services_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              searchQuery.isNotEmpty
                  ? 'No services match "$searchQuery"'
                  : 'No services found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'This service type is not available at this branch yet.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
