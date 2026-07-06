import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/features/organization/domain/entities/organization_detail.dart';
import 'package:viora_app/features/organization/domain/usecases/get_organization_details_usecase.dart';

const Color _primary = Color(0xFF2F1193);
const Color _border = Color(0xFFE8E8EE);

class VisitedOrganizationsPage extends StatefulWidget {
  final List<String> organizationIds;

  const VisitedOrganizationsPage({super.key, required this.organizationIds});

  @override
  State<VisitedOrganizationsPage> createState() =>
      _VisitedOrganizationsPageState();
}

class _VisitedOrganizationsPageState extends State<VisitedOrganizationsPage> {
  List<OrganizationDetail> _orgs = [];
  List<OrganizationDetail> _filteredOrgs = [];
  bool _loading = true;
  int _totalCount = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrganizations() async {
    final getOrgDetails = sl<GetOrganizationDetailsUseCase>();
    final results = await Future.wait(
      widget.organizationIds.map((id) => getOrgDetails(
        GetOrganizationDetailsParams(organizationId: id),
      )),
    );

    final loaded = <OrganizationDetail>[];
    for (final result in results) {
      result.fold(
        (_) {},
        (org) => loaded.add(org),
      );
    }

    if (mounted) {
      setState(() {
        _orgs = loaded;
        _filteredOrgs = loaded;
        _totalCount = widget.organizationIds.length;
        _loading = false;
      });
    }
  }

  void _filterOrganizations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOrgs = List.from(_orgs);
      } else {
        _filteredOrgs = _orgs.where((org) =>
          org.name.toLowerCase().contains(query.toLowerCase()),
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_orgs.isNotEmpty) _buildSearchBar(),
            if (_loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filteredOrgs.isEmpty)
              _buildEmpty()
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: _filteredOrgs.length,
                  itemBuilder: (context, index) =>
                      _buildOrgCard(_filteredOrgs[index], index),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 20, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Visited Organizations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_totalCount',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: TextField(
        controller: _searchController,
        onChanged: _filterOrganizations,
        decoration: InputDecoration(
          hintText: 'Search organizations...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, color: Colors.grey.shade400, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    _filterOrganizations('');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF5F5F9),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_rounded,
                size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No matching organizations'
                  : 'No visited organizations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try a different search term'
                  : 'Organizations you visit will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrgCard(OrganizationDetail org, int index) {
    final initials = org.name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join();
    final servicesText = org.servicesProvided.take(2).join(', ');

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 80).clamp(0, 400)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => context.push(
            '${AppRoutes.organizationDetail}?id=${org.id}',
          ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        org.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            org.country,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      if (servicesText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          servicesText,
                          style: TextStyle(
                            fontSize: 12,
                            color: _primary.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 22, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
