import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/features/search/domain/entities/organization.dart';
import 'package:viora_app/features/search/representation/bloc/search_bloc.dart';
import 'package:viora_app/features/search/representation/bloc/search_event.dart';
import 'package:viora_app/features/search/representation/bloc/search_state.dart';

const Color _primary = Color(0xFF2F1193);
const Color _accent = Color(0xFF4A37A0);
const Color _bg = Color(0xFFF5F3FC);

class SearchPage extends StatefulWidget {
  final String? initialQuery;
  final String? initialCountry;
  final String? initialServiceType;
  final double? initialMinRating;

  const SearchPage({
    super.key,
    this.initialQuery,
    this.initialCountry,
    this.initialServiceType,
    this.initialMinRating,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  int _activeFilterCount = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _focusNode = FocusNode();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();

    final bloc = context.read<SearchBloc>();
    bloc.add(const LoadFilterOptions());
    _activeFilterCount = bloc.activeFilterCount;

    bloc.stream.listen((state) {
      if (!mounted) return;
      final count = context.read<SearchBloc>().activeFilterCount;
      if (count != _activeFilterCount) {
        setState(() => _activeFilterCount = count);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasInitialFilters = widget.initialCountry != null ||
          widget.initialServiceType != null ||
          (widget.initialMinRating ?? 0) > 0;
      if (hasInitialFilters) {
        final bloc = context.read<SearchBloc>();
        bloc.add(SearchOrganizations(
          query: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          country: widget.initialCountry,
          serviceType: widget.initialServiceType,
          minimumRating: widget.initialMinRating ?? 0,
        ));
      }
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _performSearch({int page = 1}) {
    final query = _searchController.text.trim();
    final bloc = context.read<SearchBloc>();
    bloc.add(SearchOrganizations(
      query: query.isEmpty ? null : query,
      country: bloc.selectedCountry,
      serviceType: bloc.selectedServiceType,
      minimumRating: bloc.minRating,
      sortBy: bloc.sortBy,
      page: page,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(child: _buildResults()),
            ],
          ),
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
            'Search Providers',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
          child: Row(
            children: [
              const Icon(Icons.search, color: _accent, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onSubmitted: (_) => _performSearch(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: _activeFilterCount > 0
                        ? 'Search in filtered results...'
                        : 'Search by name...',
                    hintStyle: const TextStyle(
                        color: Color(0xFF9E94C5), fontSize: 16),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    _debounce?.cancel();
                    if (value.isEmpty) {
                      context.read<SearchBloc>().add(const ClearSearch());
                    } else {
                      _debounce =
                          Timer(const Duration(milliseconds: 400), () {
                        _performSearch();
                      });
                    }
                  },
                ),
              ),
              GestureDetector(
                onTap: () => _showFilterSheet(context),
                child: _activeFilterCount > 0
                    ? Badge(
                        label: Text('$_activeFilterCount'),
                        child: const Icon(Icons.tune, color: _accent),
                      )
                    : const Icon(Icons.tune, color: _accent),
              ),
            ],
          ),
        ),
        if (_activeFilterCount > 0) ...[
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
            child: _buildActiveFilterChips(),
          ),
        ],
      ],
    );
  }

  Widget _buildActiveFilterChips() {
    final bloc = context.read<SearchBloc>();
    final country = bloc.selectedCountry;
    final serviceType = bloc.selectedServiceType;
    final minRating = bloc.minRating;
    final sortBy = bloc.sortBy;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (country != null)
            _buildFilterChip(country, () {
              final bloc = context.read<SearchBloc>();
              context.read<SearchBloc>().add(SearchOrganizations(
                    query: _searchController.text.trim().isEmpty
                        ? null
                        : _searchController.text.trim(),
                    country: null,
                    serviceType: bloc.selectedServiceType,
                    minimumRating: bloc.minRating,
                    sortBy: bloc.sortBy,
                  ));
              setState(() {});
            }),
          if (serviceType != null)
            _buildFilterChip(serviceType, () {
              context.read<SearchBloc>().add(SearchOrganizations(
                    query: _searchController.text.trim().isEmpty
                        ? null
                        : _searchController.text.trim(),
                    country: context.read<SearchBloc>().selectedCountry,
                    serviceType: null,
                    minimumRating: context.read<SearchBloc>().minRating,
                    sortBy: context.read<SearchBloc>().sortBy,
                  ));
              setState(() {});
            }),
          if (minRating > 0)
            _buildFilterChip('Rating: ${minRating.toStringAsFixed(1)}', () {
              context.read<SearchBloc>().add(SearchOrganizations(
                    query: _searchController.text.trim().isEmpty
                        ? null
                        : _searchController.text.trim(),
                    country: context.read<SearchBloc>().selectedCountry,
                    serviceType: context.read<SearchBloc>().selectedServiceType,
                    minimumRating: 0,
                    sortBy: context.read<SearchBloc>().sortBy,
                  ));
              setState(() {});
            }),
          if (sortBy != null)
            _buildFilterChip('Sort: $sortBy', () {
              context.read<SearchBloc>().add(SearchOrganizations(
                    query: _searchController.text.trim().isEmpty
                        ? null
                        : _searchController.text.trim(),
                    country: context.read<SearchBloc>().selectedCountry,
                    serviceType: context.read<SearchBloc>().selectedServiceType,
                    minimumRating: context.read<SearchBloc>().minRating,
                    sortBy: null,
                  ));
              setState(() {});
            }),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _clearAllFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Clear all',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child:
                const Icon(Icons.close, size: 14, color: _primary),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    context.read<SearchBloc>().add(const ClearSearch());
    setState(() {});
  }

  Widget _buildResults() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading) {
          return const Center(
            child: CircularProgressIndicator(color: _primary),
          );
        }

        if (state is SearchError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Color(0xFFFF6B6B)),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _performSearch,
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

        if (state is SearchEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 64, color: Color(0xFFD0D0D0)),
                  SizedBox(height: 16),
                  Text(
                    'No providers found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black38,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try adjusting your search',
                    style: TextStyle(fontSize: 14, color: Colors.black38),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is SearchOrganizationsLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Text(
                  '${state.totalCount} result${state.totalCount == 1 ? '' : 's'} found',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.organizations.length,
                  itemBuilder: (context, index) {
                    return _buildOrganizationCard(state.organizations[index], index);
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    final bloc = context.read<SearchBloc>();
    final currentState = bloc.state;
    List<String> countries = [];
    List<String> serviceTypes = [];
    String? sheetCountry;
    String? sheetServiceType;
    double sheetMinRating = 0;
    String? sheetSortBy;

    if (currentState is SearchOrganizationsLoaded) {
      countries = currentState.countries;
      serviceTypes = currentState.serviceTypes;
      sheetCountry = currentState.selectedCountry;
      sheetServiceType = currentState.selectedServiceType;
      sheetMinRating = currentState.minRating;
      sheetSortBy = currentState.sortBy;
    } else if (currentState is SearchEmpty) {
      countries = currentState.countries;
      serviceTypes = currentState.serviceTypes;
      sheetCountry = currentState.selectedCountry;
      sheetServiceType = currentState.selectedServiceType;
      sheetMinRating = currentState.minRating;
      sheetSortBy = currentState.sortBy;
    } else if (currentState is SearchFilterOptionsLoaded) {
      countries = currentState.countries;
      serviceTypes = currentState.serviceTypes;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Filter Organizations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (countries.isNotEmpty) ...[
                    Text(
                      'Country',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: sheetCountry,
                        hint: const Text('All countries'),
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: Colors.white,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All countries'),
                          ),
                          ...countries.map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setSheetState(
                              () => sheetCountry = val);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (serviceTypes.isNotEmpty) ...[
                    Text(
                      'Service Type',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: sheetServiceType,
                        hint: const Text('All services'),
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: Colors.white,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All services'),
                          ),
                          ...serviceTypes.map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setSheetState(
                              () => sheetServiceType = val);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'Minimum Rating',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: sheetMinRating,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: sheetMinRating == 0
                        ? 'Any'
                        : sheetMinRating.toStringAsFixed(1),
                    activeColor: _primary,
                    onChanged: (val) {
                      setSheetState(
                          () => sheetMinRating = val);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildSortChip('Latest', sheetSortBy,
                          (val) {
                        setSheetState(
                            () => sheetSortBy = val);
                      }),
                      _buildSortChip('Rating', sheetSortBy,
                          (val) {
                        setSheetState(
                            () => sheetSortBy = val);
                      }),
                      _buildSortChip('Name', sheetSortBy,
                          (val) {
                        setSheetState(
                            () => sheetSortBy = val);
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        final query =
                            _searchController.text.trim();
                        bloc.add(
                          SearchOrganizations(
                            query: query.isEmpty
                                ? null
                                : query,
                            country: sheetCountry,
                            serviceType:
                                sheetServiceType,
                            minimumRating:
                                sheetMinRating,
                            sortBy: sheetSortBy,
                          ),
                        );
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortChip(
      String label, String? current, Function(String?) onTap) {
    final isSelected = current == label;
    return GestureDetector(
      onTap: () => onTap(isSelected ? null : label),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primary : _bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : _accent,
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationCard(Organization org, int index) {
    final initials = org.name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 300)),
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
      child: GestureDetector(
        onTap: () => context.push(
          '${AppRoutes.organizationDetail}?id=${org.id}&rating=${org.ratingOutOfTen}&ratingsCount=${org.ratingsCount}',
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8E8EE)),
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        org.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              org.country,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF28F0A8).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 16, color: Color(0xFFF5A623)),
                      const SizedBox(width: 2),
                      Text(
                        org.ratingOutOfTen.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF28F0A8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (org.servicesProvided.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: org.servicesProvided.map((service) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      service,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _accent,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }
}
