import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/core/functions/service_type_mapper.dart';
import 'package:viora_app/features/search/domain/entities/branch.dart';
import 'package:viora_app/features/search/representation/bloc/search_bloc.dart';
import 'package:viora_app/features/search/representation/bloc/search_event.dart';
import 'package:viora_app/features/search/representation/bloc/search_state.dart';

const Color _primary = Color(0xFF2F1193);
const Color _bg = Color(0xFFF5F3FC);

class BranchSearchPage extends StatefulWidget {
  final String specialty;

  const BranchSearchPage({super.key, required this.specialty});

  @override
  State<BranchSearchPage> createState() => _BranchSearchPageState();
}

class _BranchSearchPageState extends State<BranchSearchPage>
    with SingleTickerProviderStateMixin {
  double _radiusMeters = 500;
  double _minRating = 0;
  bool _isOpenNow = false;
  String? _orderBy;
  bool _showFilters = false;

  bool _isGettingLocation = true;
  String? _locationError;
  double? _latitude;
  double? _longitude;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
    _scrollController.addListener(_onScroll);
    _getLocationAndSearch();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _getLocationAndSearch() async {
    if (!mounted) return;
    debugPrint('[BranchSearch] ===== _getLocationAndSearch STARTED =====');
    setState(() {
      _isGettingLocation = true;
      _locationError = null;
    });

    try {
      final bloc = context.read<SearchBloc>();
      final locationService = bloc.locationService;

      debugPrint('[BranchSearch] Step 1: Checking if location service is enabled...');
      final serviceEnabled = await locationService.isLocationServiceEnabled();
      debugPrint('[BranchSearch] Step 1 result — serviceEnabled: $serviceEnabled');
      if (!mounted) return;
      if (!serviceEnabled) {
        debugPrint('[BranchSearch] ❌ Location services DISABLED — showing error');
        setState(() {
          _isGettingLocation = false;
          _locationError =
              'Location services are disabled.\nPlease enable them to search nearby branches.';
        });
        return;
      }
      debugPrint('[BranchSearch] ✅ Location services enabled');

      debugPrint('[BranchSearch] Step 2: Checking/requesting location permission...');
      final hasPermission = await locationService.checkAndRequestPermission();
      debugPrint('[BranchSearch] Step 2 result — hasPermission: $hasPermission');
      if (!mounted) return;
      if (!hasPermission) {
        debugPrint('[BranchSearch] ❌ Location permission DENIED — showing error');
        setState(() {
          _isGettingLocation = false;
          _locationError =
              'Location permission is required\nto search nearby branches.';
        });
        return;
      }
      debugPrint('[BranchSearch] ✅ Location permission granted');

      debugPrint('[BranchSearch] Step 3: Getting current position...');
      final position = await locationService.getCurrentPosition();
      if (position != null) {
        _latitude = position.latitude;
        _longitude = position.longitude;
        debugPrint('[BranchSearch] ✅ Position obtained — lat=$_latitude, lng=$_longitude');
      } else {
        debugPrint('[BranchSearch] ⚠️ Position is null — will search without location');
      }

      if (!mounted) return;
      setState(() => _isGettingLocation = false);
      debugPrint('[BranchSearch] ===== Location step done, proceeding to _search() =====');
      _search();
    } catch (e, stack) {
      debugPrint('[BranchSearch] ❌ Unexpected location error: $e');
      debugPrint('[BranchSearch] Stack trace: $stack');
      if (!mounted) return;
      setState(() {
        _isGettingLocation = false;
        _locationError = 'Failed to get your location.\nPlease try again.';
      });
    }
  }

  void _search({int page = 1}) {
    final hasLocation = _latitude != null && _longitude != null;

    debugPrint('[BranchSearch] ===== _search(page=$page) =====');
    debugPrint('[BranchSearch]   lat: $_latitude');
    debugPrint('[BranchSearch]   lng: $_longitude');
    debugPrint('[BranchSearch]   hasLocation: $hasLocation');
    debugPrint('[BranchSearch]   specialty: ${widget.specialty}');
    debugPrint('[BranchSearch]   radiusMeters: $_radiusMeters');
    debugPrint('[BranchSearch]   minRating: $_minRating');
    debugPrint('[BranchSearch]   isOpenNow: $_isOpenNow');
    debugPrint('[BranchSearch]   orderBy: $_orderBy');
    debugPrint('[BranchSearch]   SENDING SearchBranches event → lat=$_latitude, lng=$_longitude, '
        'servicesFilter=[${widget.specialty}], distanceWithinMeters=${hasLocation ? _radiusMeters : "null (no location)"}');

    context.read<SearchBloc>().add(SearchBranches(
          latitude: _latitude,
          longitude: _longitude,
          distanceWithinMeters: hasLocation ? _radiusMeters : null,
          servicesFilter: [mapServiceType(widget.specialty)],
          minimumRating: _minRating,
          orderBy: _orderBy != null ? [_orderBy!] : null,
          isCurrentlyOpen: _isOpenNow ? true : null,
          page: page,
        ));
  }

  void _loadMore() {
    final state = context.read<SearchBloc>().state;
    if (state is SearchBranchesLoaded && state.hasNextPage && !_isLoadingMore) {
      _isLoadingMore = true;
      context.read<SearchBloc>().add(const LoadMoreBranches());
    }
  }

  void _onFiltersChanged() {
    _search();
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
              _buildFilterToggle(),
              if (_showFilters) _buildFiltersPanel(),
              Expanded(child: _buildBody()),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nearby Branches',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  widget.specialty,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildFilterToggle() {
    final hasFiltersActive = _minRating > 0 || _isOpenNow || _orderBy != null || _radiusMeters != 500;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _showFilters ? _primary : _bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _showFilters ? _primary : _primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showFilters ? Icons.filter_list_off : Icons.tune,
                    size: 16,
                    color: _showFilters ? Colors.white : _primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _showFilters ? 'Hide Filters' : 'Filters',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _showFilters ? Colors.white : _primary.withValues(alpha: 0.7),
                    ),
                  ),
                  if (hasFiltersActive && !_showFilters) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B6B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _getLocationAndSearch,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.my_location, size: 16, color: _primary.withValues(alpha: 0.7)),
                  const SizedBox(width: 6),
                  Text(
                    'Refresh',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _primary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _radiusMeters = 500;
                    _minRating = 0;
                    _isOpenNow = false;
                    _orderBy = null;
                  });
                  _onFiltersChanged();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRadiusSlider(),
          const Divider(height: 24),
          _buildRatingSlider(),
          const Divider(height: 24),
          _buildOpenNowToggle(),
          const Divider(height: 24),
          _buildSortOptions(),
        ],
      ),
    );
  }

  Widget _buildRadiusSlider() {
    const List<double> radiusOptions = [100, 200, 500, 1000, 2000, 5000];
    final selectedIndex = radiusOptions
        .indexWhere((r) => r >= _radiusMeters)
        .clamp(0, radiusOptions.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Radius',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              _radiusMeters >= 1000
                  ? '${(_radiusMeters / 1000).toStringAsFixed(1)} km'
                  : '${_radiusMeters.toInt()} m',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: _primary,
            inactiveTrackColor: _primary.withValues(alpha: 0.15),
            thumbColor: _primary,
            overlayColor: _primary.withValues(alpha: 0.08),
            trackHeight: 4,
          ),
          child: Slider(
            value: selectedIndex.toDouble(),
            min: 0,
            max: (radiusOptions.length - 1).toDouble(),
            divisions: radiusOptions.length - 1,
            onChanged: (val) {
              setState(() {
                _radiusMeters = radiusOptions[val.round()];
              });
            },
            onChangeEnd: (_) => _onFiltersChanged(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('100m',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              Text('5km',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Minimum Rating',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              _minRating == 0 ? 'Any' : _minRating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: _primary,
            inactiveTrackColor: _primary.withValues(alpha: 0.15),
            thumbColor: _primary,
            overlayColor: _primary.withValues(alpha: 0.08),
            trackHeight: 4,
          ),
          child: Slider(
            value: _minRating,
            min: 0,
            max: 10,
            divisions: 20,
            onChanged: (val) {
              setState(() => _minRating = val);
            },
            onChangeEnd: (_) => _onFiltersChanged(),
          ),
        ),
      ],
    );
  }

  Widget _buildOpenNowToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Open Now',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() => _isOpenNow = !_isOpenNow);
            _onFiltersChanged();
          },
          child: Container(
            width: 48,
            height: 26,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: _isOpenNow ? _primary : Colors.grey.shade300,
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment:
                  _isOpenNow ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(3),
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    final isDistance = _orderBy == null || _orderBy == 'distance';
    final isRating = _orderBy == 'rating';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildSortChip('Distance', isDistance),
            const SizedBox(width: 8),
            _buildSortChip('Rating', isRating),
          ],
        ),
      ],
    );
  }

  Widget _buildSortChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _orderBy = isSelected ? null : label.toLowerCase();
        });
        _onFiltersChanged();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isGettingLocation) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _primary),
            SizedBox(height: 16),
            Text(
              'Getting your location...',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    if (_locationError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_off,
                    size: 48, color: Color(0xFFFF6B6B)),
              ),
              const SizedBox(height: 20),
              Text(
                _locationError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _getLocationAndSearch,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  _latitude = null;
                  _longitude = null;
                  setState(() => _locationError = null);
                  _search();
                },
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Search without location'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: BorderSide(color: _primary.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _search,
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

        if (state is SearchBranchesLoaded) {
          if (state.branches.isEmpty) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _bg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.search_off,
                        size: 48, color: Color(0xFFD0D0D0)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No nearby branches',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'There are no near branches for ${widget.specialty} around you within ${_radiusMeters >= 1000 ? '${(_radiusMeters / 1000).toStringAsFixed(1)} km' : '${_radiusMeters.toInt()} m'}.\nTry increasing the radius or adjusting filters.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _radiusMeters = 5000;
                        _showFilters = true;
                      });
                      _onFiltersChanged();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _bg,
                      foregroundColor: _primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Expand to 5 km'),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Text(
                  '${state.totalCount} branch${state.totalCount == 1 ? '' : 'es'} found',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.branches.length + (state.hasNextPage ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.branches.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(color: _primary),
                        ),
                      );
                    }
                    return _buildBranchCard(state.branches[index], index);
                  },
                ),
              ),
            ],
          );
        }

        if (state is SearchBranchesLoadingMore) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Text(
                  '${state.totalCount} branch${state.totalCount == 1 ? '' : 'es'} found',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.branches.length + 1,
                  itemBuilder: (context, index) {
                    if (index == state.branches.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(color: _primary),
                        ),
                      );
                    }
                    return _buildBranchCard(state.branches[index], index);
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

  Widget _buildBranchCard(Branch branch, int index) {
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
                      branch.organizationName
                          .split(' ')
                          .where((e) => e.isNotEmpty)
                          .map((e) => e[0])
                          .take(2)
                          .join(),
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
                        branch.organizationName,
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
                              branch.address,
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
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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
                            branch.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF28F0A8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildOpenBadge(branch.isOpen),
                  ],
                ),
              ],
            ),
            if (branch.coverImageUrl != null &&
                branch.coverImageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  branch.coverImageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 120,
                      color: _bg,
                      child: const Center(
                        child: CircularProgressIndicator(color: _primary),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOpenBadge(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOpen
            ? const Color(0xFF28F0A8).withValues(alpha: 0.15)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isOpen ? 'Open' : 'Closed',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isOpen ? const Color(0xFF1B8A5E) : Colors.grey.shade500,
        ),
      ),
    );
  }
}
