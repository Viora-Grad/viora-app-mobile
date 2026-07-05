import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/features/organization/data/datasources/local/saved_organizations_local.dart';

const Color _primary = Color(0xFF2F1193);
const Color _border = Color(0xFFE8E8EE);

class SavedOrganizationsPage extends StatefulWidget {
  const SavedOrganizationsPage({super.key});

  @override
  State<SavedOrganizationsPage> createState() =>
      _SavedOrganizationsPageState();
}

class _SavedOrganizationsPageState extends State<SavedOrganizationsPage> {
  late final SavedOrganizationsLocal _savedLocal;
  List<SavedOrganization> _savedOrgs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _savedLocal = sl<SavedOrganizationsLocal>();
    _load();
  }

  Future<void> _load() async {
    final orgs = await _savedLocal.getSavedOrganizations();
    if (mounted) {
      setState(() {
        _savedOrgs = orgs;
        _loading = false;
      });
    }
  }

  Future<void> _removeOrg(SavedOrganization org) async {
    await _savedLocal.toggleSaved(
      id: org.id,
      name: org.name,
      logoId: org.logoId,
    );
    if (!mounted) return;
    setState(() => _savedOrgs.removeWhere((o) => o.id == org.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from bookmarks'),
        backgroundColor: const Color(0xFF28F0A8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_savedOrgs.isEmpty)
              _buildEmpty()
            else
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: _savedOrgs.length,
                  itemBuilder: (context, index) =>
                      _buildOrgCard(_savedOrgs[index], index),
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
            'Saved Organizations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border_rounded,
                size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Text(
              'No saved organizations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookmark organizations you like\n to find them easily later',
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

  Widget _buildOrgCard(SavedOrganization org, int index) {
    final initials = org.name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join();

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
              children: [
                Container(
                  width: 48,
                  height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F1193),
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
                  child: Text(
                    org.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _removeOrg(org),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.close_rounded,
                        size: 18, color: Colors.grey.shade500),
                  ),
                ),
                const SizedBox(width: 4),
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
