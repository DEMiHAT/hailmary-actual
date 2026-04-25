import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'vitals_screen.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 5 tabs based on screenshot: SpO2, Adherence, Trend, Symptoms, Doctor
    _tabController = TabController(length: 5, vsync: this, initialIndex: 1); // Select Adherence by default
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health Monitoring',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Multimodal vitals • 7 interlocking modules',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Custom Tab Bar
            SizedBox(
              height: 40,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                indicator: const BoxDecoration(), // Remove default underline indicator
                dividerColor: Colors.transparent,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textTertiary,
                labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
                tabs: [
                  _buildTab('SpO₂', 0),
                  _buildTab('Adherence', 1),
                  _buildTab('Trend', 2),
                  _buildTab('Symptoms', 3),
                  _buildTab('Doctor', 4),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const VitalsScreen(isEmbedded: true), // We will pass isEmbedded:true to remove its AppBar later
                  const _AdherenceTab(),
                  const _WeightTab(),
                  const _SymptomsTab(),
                  const _DoctorLocatorTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        final isSelected = _tabController.index == index;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.divider : AppColors.divider.withOpacity(0.5),
            ),
          ),
          child: Text(text),
        );
      },
    );
  }
}

// ── Adherence Tab Component ─────────────────────────────────

class _AdherenceTab extends StatelessWidget {
  const _AdherenceTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Medication Adherence',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '93%',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Progress Bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: AppColors.divider,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.93,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [AppColors.safe, AppColors.warning],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                Text(
                  '14-day rolling window • Override: <60% or 3+ consecutive missed',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Calendar section
                Text(
                  'Last 14 Days',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Days header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                    return SizedBox(
                      width: 32,
                      child: Center(
                        child: Text(
                          day,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 8),
                
                // Week 1 (from screenshot)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.missed),
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.taken),
                  ],
                ),
                const SizedBox(height: 8),
                // Week 2 (from screenshot)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.missed),
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.taken),
                  ],
                ),
                const SizedBox(height: 8),
                // Next week padding (from screenshot, has some empty dots)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _DayCell(status: _DayStatus.empty),
                    _DayCell(status: _DayStatus.empty),
                    const SizedBox(width: 32),
                    const SizedBox(width: 32),
                    const SizedBox(width: 32),
                    const SizedBox(width: 32),
                    const SizedBox(width: 32),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Alert Box
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
                    '2 missed doses detected. ASHA worker notified via Ni-Kshay dashboard.',
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
          
          const SizedBox(height: 100), // padding for bottom nav
        ],
      ),
    );
  }
}

enum _DayStatus { taken, missed, empty }

class _DayCell extends StatelessWidget {
  final _DayStatus status;

  const _DayCell({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Widget child;

    switch (status) {
      case _DayStatus.taken:
        bgColor = AppColors.safe.withOpacity(0.15);
        child = Icon(Icons.check_rounded, size: 16, color: AppColors.safe);
        break;
      case _DayStatus.missed:
        bgColor = AppColors.emergency.withOpacity(0.15);
        child = Icon(Icons.close_rounded, size: 16, color: AppColors.emergency);
        break;
      case _DayStatus.empty:
      default:
        bgColor = AppColors.divider.withOpacity(0.3);
        child = Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.textTertiary.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        );
        break;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: child),
    );
  }
}

// ── Weight Tab Component ─────────────────────────────────

class _WeightTab extends StatelessWidget {
  const _WeightTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Weekly Health Trend',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.safe.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('+0.8 kg', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.safe)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('64.8', style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.0)),
                    const SizedBox(width: 8),
                    Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('kg', style: GoogleFonts.inter(fontSize: 16, color: AppColors.textTertiary))),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Target: 66.0 kg (Healthy BMI Range)', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                
                const SizedBox(height: 32),
                
                // Fake Bar Chart Trend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _WeightBar(height: 40, weight: '64.0', label: 'W1'),
                    _WeightBar(height: 42, weight: '64.1', label: 'W2'),
                    _WeightBar(height: 46, weight: '64.3', label: 'W3'),
                    _WeightBar(height: 60, weight: '64.8', label: 'W4', isCurrent: true),
                    _WeightBar(height: 80, weight: '66.0', label: 'TGT', isTarget: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _WeightBar extends StatelessWidget {
  final double height;
  final String weight;
  final String label;
  final bool isCurrent;
  final bool isTarget;

  const _WeightBar({required this.height, required this.weight, required this.label, this.isCurrent = false, this.isTarget = false});

  @override
  Widget build(BuildContext context) {
    Color barColor = AppColors.divider.withOpacity(0.5);
    if (isCurrent) barColor = AppColors.safe;
    if (isTarget) barColor = AppColors.info.withOpacity(0.3);

    return Column(
      children: [
        Text(weight, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: isCurrent ? AppColors.safe : AppColors.textTertiary)),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: height,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500, color: isCurrent ? AppColors.safe : AppColors.textSecondary)),
      ],
    );
  }
}

// ── Symptoms Tab Component ─────────────────────────────────

class _SymptomsTab extends StatelessWidget {
  const _SymptomsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Symptoms Log',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Last updated: Today 9:00 AM', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary)),
                const SizedBox(height: 24),
                
                _SymptomRow(icon: Icons.thermostat_rounded, name: 'Fever', severity: 'None', color: AppColors.safe),
                const SizedBox(height: 16),
                _SymptomRow(icon: Icons.sick_rounded, name: 'Fatigue', severity: 'Mild', color: AppColors.warning),
                const SizedBox(height: 16),
                _SymptomRow(icon: Icons.monitor_heart_rounded, name: 'Chest Pain', severity: 'None', color: AppColors.safe),
                const SizedBox(height: 16),
                _SymptomRow(icon: Icons.bloodtype_rounded, name: 'Haemoptysis', severity: 'None', color: AppColors.safe),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _SymptomRow extends StatelessWidget {
  final IconData icon;
  final String name;
  final String severity;
  final Color color;

  const _SymptomRow({required this.icon, required this.name, required this.severity, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        ),
        Text(severity, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}

// ── Doctor Locator Tab Component ─────────────────────────────────

class _DoctorLocatorTab extends StatelessWidget {
  const _DoctorLocatorTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.info.withOpacity(0.14), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.local_hospital_rounded, color: AppColors.info, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Nearest Verified Doctor',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(color: AppColors.safe.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          Icon(Icons.verified_rounded, size: 14, color: AppColors.safe),
                          const SizedBox(width: 4),
                          Text('Verified', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.safe)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'District TB Centre, Government Chest Hospital',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  '2.4 km away • DOTS / TB treatment center • Government priority',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _DoctorAction(icon: Icons.call_rounded, label: 'Call', color: AppColors.safe)),
                    const SizedBox(width: 12),
                    Expanded(child: _DoctorAction(icon: Icons.directions_rounded, label: 'Directions', color: AppColors.info)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _DoctorAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DoctorAction({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.35)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
