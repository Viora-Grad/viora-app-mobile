import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/features/organization/domain/entities/branch_detail.dart';
import 'package:viora_app/features/organization/domain/entities/branch_schedule.dart';
import 'package:viora_app/features/organization/representation/bloc/organization_bloc.dart';
import 'package:viora_app/features/organization/representation/bloc/organization_event.dart';
import 'package:viora_app/features/organization/representation/bloc/organization_state.dart';
import 'package:viora_app/features/reviews/representation/bloc/review_bloc.dart';
import 'package:viora_app/features/reviews/representation/widgets/reviews_section.dart';

const Color _primary = Color(0xFF0D7C66);
const Color _accent = Color(0xFF14A085);
const Color _bg = Color(0xFFF0FCF8);
const Color _border = Color(0xFFC8E6DE);
const Color _surface = Color(0xFFF7FFFD);

const _serviceIcons = {
  'Orthopedics': Icons.biotech,
  'Cardiology': Icons.favorite,
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
  'Emergency': Icons.local_hospital,
  'Dental': Icons.cleaning_services,
};

const _serviceDescriptions = {
  'Orthopedics':
      'Diagnosis and treatment of musculoskeletal system disorders including bones, joints, ligaments, tendons, and muscles. Services include fracture care, joint replacement, sports injuries, and minimally invasive arthroscopic surgery.',
  'Cardiology':
      'Comprehensive heart and vascular care including diagnostic tests (ECG, echocardiogram), interventional procedures (angiography, stenting), heart rhythm management, and preventive cardiology programs.',
  'Dermatology':
      'Medical and surgical care for skin, hair, and nail conditions including acne, eczema, psoriasis, skin cancer screening, mole checks, and cosmetic dermatology treatments.',
  'Psychiatry':
      'Assessment, diagnosis, and treatment of mental health conditions including depression, anxiety, bipolar disorder, and schizophrenia through medication management, therapy, and holistic support.',
  'Neurology':
      'Diagnosis and treatment of disorders affecting the brain, spinal cord, and nervous system including migraines, epilepsy, Parkinson\'s disease, multiple sclerosis, and stroke recovery.',
  'Ophthalmology':
      'Medical and surgical eye care including vision testing, cataract surgery, glaucoma management, retinal disorders, and laser vision correction procedures.',
  'Pediatrics':
      'Comprehensive healthcare for infants, children, and adolescents from birth through young adulthood including well-child visits, vaccinations, developmental screenings, and acute illness management.',
  'Gynecology':
      'Women\'s health services focusing on the reproductive system including routine exams, pap smears, contraception, fertility counseling, and management of reproductive health conditions.',
  'Urology':
      'Medical and surgical care for the urinary tract in both genders and the male reproductive system including kidney stones, prostate issues, incontinence, and urologic cancers.',
  'Gastroenterology':
      'Diagnosis and treatment of digestive system disorders including acid reflux, IBS, Crohn\'s disease, ulcerative colitis, liver conditions, and colon cancer screening via endoscopy.',
  'Pulmonology':
      'Diagnosis and management of respiratory and lung conditions including asthma, COPD, pneumonia, pulmonary fibrosis, sleep apnea, and pulmonary function testing.',
  'Endocrinology':
      'Specialized care for hormone-related disorders including diabetes management, thyroid conditions, osteoporosis, adrenal disorders, and pituitary gland abnormalities.',
  'Rheumatology':
      'Diagnosis and treatment of autoimmune and inflammatory conditions affecting joints, muscles, and connective tissues including rheumatoid arthritis, lupus, and gout.',
  'Oncology':
      'Comprehensive cancer care including chemotherapy, immunotherapy, radiation therapy, targeted therapy, and supportive care for patients with various types of cancer.',
  'Radiology':
      'Medical imaging services including X-ray, MRI, CT scans, ultrasound, mammography, and nuclear medicine for accurate diagnosis and treatment planning.',
  'Anesthesiology':
      'Pain management and anesthesia care for surgical procedures including general anesthesia, regional blocks, sedation, and chronic pain management interventions.',
  'Emergency Medicine':
      'Immediate medical care for acute illnesses, injuries, trauma, and life-threatening conditions with 24/7 availability and rapid diagnostic capabilities.',
  'General Surgery':
      'Surgical procedures for a wide range of conditions including abdominal surgeries, hernia repair, gallbladder removal, appendix surgery, and soft tissue procedures.',
  'Internal Medicine':
      'Evidence-based prevention, diagnosis, and treatment of adult diseases with a focus on comprehensive care, chronic disease management, and health maintenance.',
  'Otolaryngology':
      'Medical and surgical care for conditions of the ear, nose, throat, head, and neck including hearing loss, sinusitis, tonsillitis, voice disorders, and head and neck cancers.',
  'Allergy & Immunology':
      'Diagnosis and management of allergic diseases and immune system disorders including seasonal allergies, food allergies, asthma, eczema, and immunodeficiency conditions.',
  'Nephrology':
      'Diagnosis and treatment of kidney diseases including chronic kidney disease, glomerulonephritis, electrolyte disorders, hypertension management, and dialysis care.',
  'Hematology':
      'Diagnosis and management of blood disorders including anemia, clotting disorders, hemophilia, leukemia, lymphoma, and other blood cell abnormalities.',
  'Infectious Disease':
      'Diagnosis and management of complex infections including HIV/AIDS, tuberculosis, hepatitis, tropical diseases, and post-surgical infections with antibiotic stewardship.',
  'Physical Therapy':
      'Rehabilitation services to restore function, mobility, and strength after injury, surgery, or illness through targeted exercises, manual therapy, and therapeutic modalities.',
  'Sports Medicine':
      'Specialized care for sports and exercise-related injuries including ligament tears, muscle strains, concussion management, performance optimization, and injury prevention.',
};

const _dayNames = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

class BranchDetailPage extends StatefulWidget {
  final String branchId;

  const BranchDetailPage({super.key, required this.branchId});

  @override
  State<BranchDetailPage> createState() => _BranchDetailPageState();
}

class _BranchDetailPageState extends State<BranchDetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  final OrganizationBloc _orgBloc = sl<OrganizationBloc>();
  final Set<int> _expandedServices = {};

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

    _orgBloc.add(GetBranchDetail(branchId: widget.branchId));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _orgBloc,
      child: BlocProvider(
        create: (_) => sl<ReviewBloc>(),
        child: Scaffold(
          backgroundColor: _surface,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: BlocBuilder<OrganizationBloc, OrganizationState>(
            builder: (context, state) {
              if (state is OrganizationInitial || state is OrganizationLoading) {
                return _buildLoading();
              }
              if (state is OrganizationError) {
                return _buildError(state.message);
              }
              if (state is BranchDetailLoaded) {
                return _buildContent(state.branch, state.schedule);
              }
              return _buildLoading();
            },
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildLoading() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _primary),
            const SizedBox(height: 20),
            Text(
              'Loading branch details...',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded,
                  size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 20),
              Text(
                'Could not load branch',
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
                  _orgBloc.add(GetBranchDetail(branchId: widget.branchId));
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: FilledButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BranchDetail branch, List<BranchSchedule> schedule) {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(branch),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(branch),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildQuickInfoRow(branch),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildMapSection(branch),
                  ),
                  const SizedBox(height: 24),
                  _buildServicesSection(branch),
                  const SizedBox(height: 24),
                  _buildContactHoursSection(branch, schedule),
                  const SizedBox(height: 32),
                  ReviewsSection(
                      branchId: widget.branchId),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BranchDetail branch) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.organizationName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Branch Details',
                  style: const TextStyle(
                    fontSize: 16,
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

  Widget _buildHeaderSection(BranchDetail branch) {
    final initials = branch.id.isNotEmpty
        ? branch.organizationName
            .split(' ')
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
        : 'B';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.address,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.8)),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(branch.openedSinceUtc),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(branch.isCurrentlyOpen, branch.branchStatus),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isOpen, String status) {
    final effectiveStatus = status.toLowerCase();
    final bool showOpen = isOpen && effectiveStatus == 'active';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: showOpen
            ? Colors.white.withValues(alpha: 0.25)
            : Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: showOpen ? Colors.white.withValues(alpha: 0.4) : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Icon(
            showOpen ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: showOpen ? Colors.white : Colors.white.withValues(alpha: 0.7),
            size: 20,
          ),
          const SizedBox(height: 2),
          Text(
            showOpen ? 'Open' : effectiveStatus == 'active' ? 'Closed' : effectiveStatus,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: showOpen
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoRow(BranchDetail branch) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickStat(
              Icons.medical_services_outlined,
              branch.services.length.toString(),
              'Services',
            ),
          ),
          Container(width: 1, height: 36, color: _border),
          Expanded(
            child: _buildQuickStat(
              Icons.access_time_rounded,
              branch.timeZone.isNotEmpty ? branch.timeZone : '—',
              'Time Zone',
            ),
          ),
          Container(width: 1, height: 36, color: _border),
          Expanded(
            child: _buildQuickStat(
              Icons.schedule_rounded,
              branch.isCurrentlyOpen ? 'Open Now' : 'Closed',
              branch.isCurrentlyOpen ? 'Available' : 'Check Hours',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(BranchDetail branch) {
    if (branch.latitude == 0.0 && branch.longitude == 0.0) {
      return const SizedBox.shrink();
    }
    final position = LatLng(branch.latitude, branch.longitude);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(Icons.map_outlined, 'Location'),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          width: double.infinity,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                ),
                clipBehavior: Clip.antiAlias,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: position,
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.viora.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: position,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFF0D7C66),
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      final uri = Uri.parse(
                        'https://www.google.com/maps/search/?api=1&query='
                        '${branch.latitude},${branch.longitude}',
                      );
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.directions_outlined,
                        color: Color(0xFF0D7C66),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: _accent, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection(BranchDetail branch) {
    final services = branch.services;
    if (services.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.medical_services_outlined, 'Services & Specialties'),
          const SizedBox(height: 12),
          ...services.asMap().entries.map((entry) {
            final index = entry.key;
            final service = entry.value;
            final isExpanded = _expandedServices.contains(index);
            final icon = _findServiceIcon(service);
            final description = _serviceDescriptions[service] ??
                'Specialized medical care and treatment in the field of $service.';
            final color = _getServiceColor(index);

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration:
                  Duration(milliseconds: 200 + (index * 50).clamp(0, 300)),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 15 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
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
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        if (isExpanded) {
                          _expandedServices.remove(index);
                        } else {
                          _expandedServices.add(index);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(icon, color: color, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    service,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.push(
                                      '${AppRoutes.serviceListing}?branchId=${branch.id}&type=$service',
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: color.withValues(alpha: 0.2)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'View Services',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: color,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.arrow_forward_ios_rounded,
                                            size: 10, color: color),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedRotation(
                                  duration:
                                      const Duration(milliseconds: 250),
                                  turns: isExpanded ? 0.5 : 0.0,
                                  child: Icon(
                                    Icons.expand_more_rounded,
                                    color: Colors.grey.shade400,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedCrossFade(
                            firstChild: const SizedBox.shrink(),
                            secondChild: Container(
                              padding: const EdgeInsets.fromLTRB(
                                  14, 0, 14, 14),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 1,
                                    color: _border.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 3,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          description,
                                          style: TextStyle(
                                            fontSize: 13,
                                            height: 1.6,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            ),
                            crossFadeState: isExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration:
                                const Duration(milliseconds: 250),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<BusinessHour> _mergeSchedule(List<BranchSchedule> schedule) {
    final merged = <BusinessHour>[];
    for (final daySchedule in schedule) {
      if (daySchedule.shifts.isEmpty) continue;
      final earliest = daySchedule.shifts
          .map((s) => s.startTime)
          .reduce((a, b) => a.compareTo(b) <= 0 ? a : b);
      final latest = daySchedule.shifts
          .map((s) => s.endTime)
          .reduce((a, b) => a.compareTo(b) >= 0 ? a : b);
      if (earliest.isNotEmpty && latest.isNotEmpty && earliest != latest) {
        final dayIndex = _dayNames.indexWhere(
            (d) => d.toLowerCase() == daySchedule.day.toLowerCase());
        merged.add(BusinessHour(
          day: dayIndex >= 0 ? dayIndex : _dayNames.length,
          openTime: earliest,
          closeTime: latest,
        ));
      }
    }
    return merged;
  }

  Widget _buildContactHoursSection(
      BranchDetail branch, List<BranchSchedule> schedule) {
    final openHours = schedule.isNotEmpty
        ? _mergeSchedule(schedule)
        : branch.schedule
            .where((h) =>
                h.openTime.isNotEmpty &&
                h.closeTime.isNotEmpty &&
                h.openTime != h.closeTime)
            .toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              Icons.contact_mail_outlined, 'Contact & Hours'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (branch.contactEmail.isNotEmpty) ...[
                  _buildInfoRow(Icons.email_outlined,
                      'Email', branch.contactEmail, () {
                    Clipboard.setData(
                        ClipboardData(text: branch.contactEmail));
                    _showSnackBar('Email copied to clipboard');
                  }),
                  const SizedBox(height: 14),
                ],
                if (branch.address.isNotEmpty)
                  _buildInfoRow(Icons.location_on_outlined,
                      'Address', branch.address, () {
                    Clipboard.setData(
                        ClipboardData(text: branch.address));
                    _showSnackBar('Address copied to clipboard');
                  }),
                if (openHours.isNotEmpty) ...[
                  const Divider(height: 28),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.schedule_rounded,
                            size: 20, color: _accent),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Business Hours',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...openHours.map((hour) {
                    final dayName = hour.day >= 0 && hour.day < 7
                        ? _dayNames[hour.day]
                        : 'Day ${hour.day}';
                    final timeStr =
                        '${_formatTime(hour.openTime)} - ${_formatTime(hour.closeTime)}';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: _accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.copy_rounded, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: _accent),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Color _getServiceColor(int index) {
    const colors = [
      Color(0xFF0D7C66),
      Color(0xFFE88D2F),
      Color(0xFF4A6FA5),
      Color(0xFFC0392B),
      Color(0xFF8E44AD),
      Color(0xFF1ABC9C),
      Color(0xFFE67E22),
      Color(0xFF2C3E50),
      Color(0xFFD35400),
    ];
    return colors[index % colors.length];
  }

  IconData _findServiceIcon(String service) {
    for (final entry in _serviceIcons.entries) {
      if (service.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return Icons.medical_services_outlined;
  }

  void _showSnackBar(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                size: 20, color: Colors.green.shade300),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.grey.shade900,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return 'Since ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(String time) {
    if (time.isEmpty) return '—';
    final parts = time.split(':');
    if (parts.length < 2) return time;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:$minute $period';
  }
}
