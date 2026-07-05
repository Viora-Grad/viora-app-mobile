import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/features/search/domain/usecases/search_organizations_usecase.dart';

const Color _primary = Color(0xFF2F1193);
const Color _accent = Color(0xFF4A37A0);
const Color _bg = Color(0xFFF5F3FC);

class AllSpecialtiesPage extends StatefulWidget {
  const AllSpecialtiesPage({super.key});

  @override
  State<AllSpecialtiesPage> createState() => _AllSpecialtiesPageState();
}

class _AllSpecialtiesPageState extends State<AllSpecialtiesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _allSpecialties = [];
  List<String> _filteredSpecialties = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSpecialties();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSpecialties = List.from(_allSpecialties);
      } else {
        _filteredSpecialties = _allSpecialties
            .where((s) => s.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _loadSpecialties() async {
    try {
      final useCase = sl<GetServiceTypesUseCase>();
      final result = await useCase();
      result.fold(
        (failure) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
        },
        (serviceTypes) {
          setState(() {
            _allSpecialties = serviceTypes;
            _filteredSpecialties = List.from(serviceTypes);
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildContent()),
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
            'All Specialties',
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

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: _accent, size: 24),
          hintText: 'Search specialties...',
          hintStyle: const TextStyle(color: Color(0xFF9E94C5), fontSize: 16),
          border: InputBorder.none,
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _onSearchChanged();
                  },
                  child: const Icon(Icons.close,
                      color: Color(0xFF9E94C5), size: 20),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFFFF6B6B)),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadSpecialties();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredSpecialties.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Color(0xFFD0D0D0)),
            SizedBox(height: 16),
            Text(
              'No specialties found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredSpecialties.length,
      itemBuilder: (context, index) {
        final specialty = _filteredSpecialties[index];
        return GestureDetector(
          onTap: () => context.push('/branch-search', extra: specialty),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0ECF9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getSpecialtyIcon(specialty),
                  color: _primary,
                  size: 26,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                specialty,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getSpecialtyIcon(String specialty) {
    final lower = specialty.toLowerCase();
    if (lower.contains('cardio') || lower.contains('heart')) return Icons.favorite;
    if (lower.contains('derma') || lower.contains('skin')) return Icons.face;
    if (lower.contains('ortho') || lower.contains('bone')) return Icons.back_hand;
    if (lower.contains('mental') || lower.contains('psych')) return Icons.psychology;
    if (lower.contains('eye') || lower.contains('ophthal')) return Icons.visibility;
    if (lower.contains('dental') || lower.contains('teeth')) return Icons.medical_services;
    if (lower.contains('pediatr') || lower.contains('child')) return Icons.child_care;
    if (lower.contains('neuro')) return Icons.psychology;
    if (lower.contains('oncol') || lower.contains('cancer')) return Icons.monitor_heart;
    if (lower.contains('gyn') || lower.contains('women')) return Icons.pregnant_woman;
    if (lower.contains('uro')) return Icons.person;
    if (lower.contains('ent') || lower.contains('ear') || lower.contains('nose')) return Icons.hearing;
    if (lower.contains('surg')) return Icons.local_hospital;
    if (lower.contains('radiol') || lower.contains('imaging')) return Icons.science;
    if (lower.contains('lab') || lower.contains('pathol')) return Icons.biotech;
    if (lower.contains('pharma') || lower.contains('drug')) return Icons.medication;
    if (lower.contains('emerg') || lower.contains('urgent')) return Icons.emergency;
    if (lower.contains('gener') || lower.contains('family')) return Icons.person;
    return Icons.medical_services;
  }
}
