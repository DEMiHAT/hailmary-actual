import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  DateTime _lastUpdated = DateTime.now();
  bool? _morningDoseTaken = true;
  bool? _eveningDoseTaken;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _markUpdated() async {
    // sophisticated splash screen effect
    _fadeController.duration = const Duration(milliseconds: 400);
    await _fadeController.reverse();
    if (mounted) {
      setState(() => _lastUpdated = DateTime.now());
      _fadeController.duration = const Duration(milliseconds: 800);
      _fadeController.forward();
    }
  }

  void _setDoseStatus(bool isMorning, bool taken) {
    setState(() {
      if (isMorning) {
        _morningDoseTaken = taken;
      } else {
        _eveningDoseTaken = taken;
      }
      _lastUpdated = DateTime.now();
    });
  }

  void _showMedicationTrackerPopup() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final takenCount = [_morningDoseTaken, _eveningDoseTaken]
                .where((dose) => dose == true)
                .length;
            final loggedCount = [_morningDoseTaken, _eveningDoseTaken]
                .where((dose) => dose != null)
                .length;
            final status = loggedCount == 0
                ? 'Awaiting dose log'
                : 'Today: $takenCount/$loggedCount taken';

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF102A43).withOpacity(0.16),
                      blurRadius: 32,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.safe.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.medication_rounded, color: AppColors.safe),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Medication Tracker',
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Morning and evening dose log',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Have you taken your prescribed pills today?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _DoseToggleRow(
                      label: 'Morning reminder',
                      value: _morningDoseTaken,
                      onChanged: (taken) {
                        _setDoseStatus(true, taken);
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    _DoseToggleRow(
                      label: 'Evening reminder',
                      value: _eveningDoseTaken,
                      onChanged: (taken) {
                        _setDoseStatus(false, taken);
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.safe.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.safe.withOpacity(0.18)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: loggedCount > 0 && takenCount == loggedCount
                                  ? AppColors.safe
                                  : AppColors.warning,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Weekly compliance: 86%',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatLastUpdated(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '${value.day}/${value.month}/${value.year} | $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // ── Header Row ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Clinical Dashboard',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // The user icon can just tap locally or we disable it 
                        // since Profile is now in the taskbar. For now, doing nothing.
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.info,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                _LastUpdatedCard(
                  value: _formatLastUpdated(_lastUpdated),
                  onRefresh: _markUpdated,
                ),

                const SizedBox(height: 28),

                // ── TPS Progress Ring ──
                Center(
                  child: _TPSProgressRing(
                    score: 85,
                    animation: CurvedAnimation(
                      parent: _fadeController,
                      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // ── Multimodal Monitoring Dashboard ──
                Text(
                  'MULTIMODAL MONITORING',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 16),
                
                _DashboardGridRow(
                  left: _MonitoringCard(
                    icon: Icons.graphic_eq_rounded,
                    title: 'Cough Acoustics',
                    value: '0.71',
                    subtitle: 'Recovery Index',
                    weight: '30%',
                  ),
                  right: _MonitoringCard(
                    icon: Icons.medical_information_outlined,
                    title: 'Chest X-Ray / CV',
                    value: 'Mild',
                    valueColor: AppColors.warning,
                    subtitle: 'White patch detected',
                    weight: '',
                  ),
                ),
                const SizedBox(height: 14),
                _DashboardGridRow(
                  left: _MonitoringCard(
                    icon: Icons.assignment_turned_in_rounded,
                    title: 'Symptoms Log',
                    value: 'Updated',
                    valueColor: AppColors.safe,
                    subtitle: 'Fever, cough, fatigue',
                    weight: '',
                  ),
                  right: _MonitoringCard(
                    icon: Icons.water_drop_rounded,
                    title: 'SpO2 Monitor',
                    value: '97%',
                    valueColor: AppColors.safe,
                    subtitle: 'Camera PPG - Normal',
                    weight: '+10% override',
                  ),
                ),
                const SizedBox(height: 14),
                _MedicationPopupCard(
                  morningTaken: _morningDoseTaken,
                  eveningTaken: _eveningDoseTaken,
                  onTap: _showMedicationTrackerPopup,
                ),
                const SizedBox(height: 14),
                _WeeklyHealthTrendCard(),
                const SizedBox(height: 14),
                _NearestDoctorCard(),
                
                const SizedBox(height: 20),
                
                // Alert Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '2 missed doses this week - ASHA worker Lakshmi Devi has been alerted.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // ── 8-Week TPS Trend ──
                Text(
                  '8-WEEK TPS TREND',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 16),
                
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Treatment Progress',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A237E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.account_balance_rounded, size: 12, color: Color(0xFF1A237E)),
                                const SizedBox(width: 6),
                                Text(
                                  'Ni-Kshay Synced',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A237E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Bar Chart
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _TrendBar(height: 30, label: 'W1', isCurrent: false),
                          _TrendBar(height: 35, label: 'W2', isCurrent: false),
                          _TrendBar(height: 42, label: 'W3', isCurrent: false),
                          _TrendBar(height: 48, label: 'W4', isCurrent: false),
                          _TrendBar(height: 52, label: 'W5', isCurrent: false),
                          _TrendBar(height: 58, label: 'W6', isCurrent: false),
                          _TrendBar(height: 60, label: 'W7', isCurrent: false),
                          _TrendBar(height: 65, label: 'W8', isCurrent: true),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 14),
                
                // Integration Live Card
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance_rounded, color: Color(0xFF1A237E), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ni-Kshay / ASHA Integration',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Last sync: Today 09:30 AM - ID linked - FHIR R4',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.safe.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: AppColors.safe, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text('LIVE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.safe, letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Status Card ──
                GlassCard(
                  accentColor: AppColors.safe,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.safe.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          color: AppColors.safe,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'System Active',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'All services are operational',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.safe,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.safe.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}

// ── Monitoring Card ──────────────────────────────────────────

class _DashboardGridRow extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _DashboardGridRow({
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170, // Increased to fix bottom overflow
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const SizedBox(width: 14),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _MedicationPopupCard extends StatelessWidget {
  final bool? morningTaken;
  final bool? eveningTaken;
  final VoidCallback onTap;

  const _MedicationPopupCard({
    required this.morningTaken,
    required this.eveningTaken,
    required this.onTap,
  });

  int get _takenCount => [morningTaken, eveningTaken].where((dose) => dose == true).length;
  int get _loggedCount => [morningTaken, eveningTaken].where((dose) => dose != null).length;

  @override
  Widget build(BuildContext context) {
    final status = _loggedCount == 0
        ? 'Dose check pending'
        : 'Today: $_takenCount/$_loggedCount taken';

    return GlassCard(
      accentColor: AppColors.safe,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.safe.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.medication_rounded, color: AppColors.safe, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medication Reminder',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.18)),
            ),
            child: Row(
              children: [
                Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Log dose',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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

class _LastUpdatedCard extends StatelessWidget {
  final String value;
  final VoidCallback onRefresh;

  const _LastUpdatedCard({
    required this.value,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.update_rounded, size: 18, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Last Updated: $value',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            constraints: const BoxConstraints.tightFor(width: 34, height: 34),
            padding: EdgeInsets.zero,
            tooltip: 'Refresh status',
            icon: Icon(Icons.refresh_rounded, size: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _NearestDoctorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      accentColor: AppColors.info,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.local_hospital_rounded, color: AppColors.info, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nearest Verified Doctor',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Government hospital prioritized',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              _VerifiedBadge(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'District TB Centre, Government Chest Hospital',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.medical_services_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '2.4 km away - DOTS / TB treatment center',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DoctorActionButton(
                  icon: Icons.call_rounded,
                  label: 'Call',
                  color: AppColors.safe,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DoctorActionButton(
                  icon: Icons.directions_rounded,
                  label: 'Directions',
                  color: AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.safe.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.safe.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 13, color: AppColors.safe),
          const SizedBox(width: 4),
          Text(
            'Verified',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.safe,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DoctorActionButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.35)),
        padding: const EdgeInsets.symmetric(vertical: 11),
        textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _DoseToggleRow extends StatelessWidget {
  final String label;
  final bool? value;
  final ValueChanged<bool> onChanged;

  const _DoseToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: _DoseButton(
                icon: Icons.check_rounded,
                label: 'Taken',
                selected: value == true,
                color: AppColors.safe,
                onTap: () => onChanged(true),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _DoseButton(
                icon: Icons.close_rounded,
                label: 'Missed',
                selected: value == false,
                color: AppColors.emergency,
                onTap: () => onChanged(false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DoseButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _DoseButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.16) : AppColors.surface.withOpacity(0.55),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color.withOpacity(0.5) : AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: selected ? color : AppColors.textTertiary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: selected ? color : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyHealthTrendCard extends StatelessWidget {
  final List<double> values = const [64.0, 64.1, 64.2, 64.4, 64.5, 64.7, 64.8];

  const _WeeklyHealthTrendCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(Icons.show_chart_rounded, size: 22, color: AppColors.info),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Health Trend',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Weight and symptom trend',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _TrendIndicator(),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                '+0.8 kg',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'this week',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            width: double.infinity,
            child: CustomPaint(
              painter: _WeeklyTrendPainter(values: values),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.safe.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up_rounded, size: 13, color: AppColors.safe),
          const SizedBox(width: 3),
          Text(
            'Improving',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.safe,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyTrendPainter extends CustomPainter {
  final List<double> values;

  _WeeklyTrendPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = (maxValue - minValue) == 0 ? 1.0 : maxValue - minValue;
    final step = size.width / (values.length - 1);
    final path = Path();

    for (var i = 0; i < values.length; i++) {
      final x = i * step;
      final y = size.height - ((values[i] - minValue) / range * (size.height - 14)) - 7;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final gridPaint = Paint()
      ..color = AppColors.divider.withOpacity(0.45)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height - 6), Offset(size.width, size.height - 6), gridPaint);

    final paint = Paint()
      ..color = AppColors.safe
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = AppColors.safe;
    for (var i = 0; i < values.length; i++) {
      final x = i * step;
      final y = size.height - ((values[i] - minValue) / range * (size.height - 14)) - 7;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyTrendPainter oldDelegate) => oldDelegate.values != values;
}

class _MonitoringCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;
  final String subtitle;
  final String weight;

  const _MonitoringCard({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
    required this.subtitle,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: (valueColor ?? AppColors.primary).withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 21, color: valueColor ?? AppColors.primary),
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (weight.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Weight: $weight',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.textTertiary.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Trend Bar ──────────────────────────────────────────

class _TrendBar extends StatelessWidget {
  final double height;
  final String label;
  final bool isCurrent;

  const _TrendBar({
    required this.height,
    required this.label,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: height,
          decoration: BoxDecoration(
            color: isCurrent 
                ? AppColors.warning.withOpacity(0.4) 
                : AppColors.safe.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: isCurrent ? Border.all(color: AppColors.warning.withOpacity(0.8), width: 1.5) : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCurrent ? AppColors.warning : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

// ── TPS Progress Ring ──────────────────────────────────────────

class _TPSProgressRing extends StatelessWidget {
  final double score;
  final Animation<double> animation;

  const _TPSProgressRing({
    required this.score,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final currentScore = score * animation.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer Ring
            SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: currentScore / 100,
                  color: AppColors.safe,
                  backgroundColor: AppColors.divider.withOpacity(0.3),
                  strokeWidth: 16,
                ),
              ),
            ),
            
            // Inner Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TPS Score',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${currentScore.toInt()}%',
                  style: GoogleFonts.outfit(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.safe.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'On Track',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.safe,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Sweep gradient for progress to make it look premium
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      colors: [AppColors.info, AppColors.safe],
      stops: const [0.0, 1.0],
      startAngle: -math.pi / 2,
      endAngle: 2 * math.pi - (math.pi / 2),
    );
    progressPaint.shader = gradient.createShader(rect);

    // Give it a glow
    final glowPaint = Paint()
      ..color = AppColors.safe.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}
