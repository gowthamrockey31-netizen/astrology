import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/astrologer_model.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/cosmic_background.dart';
import '../../widgets/cosmic_drawer.dart';

class AstrologerDashboardScreen extends StatefulWidget {
  final Function(String route) onNavigate;

  const AstrologerDashboardScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  State<AstrologerDashboardScreen> createState() => _AstrologerDashboardScreenState();
}

class _AstrologerDashboardScreenState extends State<AstrologerDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AstrologerModel _astrologer = MockDataService.astrologers.isNotEmpty ? MockDataService.astrologers[0] : MockDataService.defaultAstrologer;
  Timer? _breakTimer;
  int _breakSecondsLeft = 0;

  void _setStatus(String status, {int? breakMinutes}) {
    if (_breakTimer != null && _breakTimer!.isActive) {
      _breakTimer!.cancel();
    }

    setState(() {
      _astrologer = AstrologerModel.fromMap({
        ..._astrologer.toMap(),
        'status': status,
        'breakTimer': breakMinutes != null ? '${breakMinutes}m' : null,
      });
    });

    if (breakMinutes != null) {
      _breakSecondsLeft = breakMinutes * 60;
      _breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_breakSecondsLeft <= 1) {
          timer.cancel();
          if (mounted) {
            setState(() {
              _astrologer = AstrologerModel.fromMap({
                ..._astrologer.toMap(),
                'status': 'online',
                'breakTimer': null,
              });
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Break completed. Automatically switched to ONLINE mode.')),
            );
          }
        } else {
          setState(() {
            _breakSecondsLeft--;
          });
        }
      });
    }
  }

  void _showIncomingCallModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDeep,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderGold, width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.ring_volume_rounded, color: AppColors.lightGold),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Incoming Consultation Request',
                style: GoogleFonts.cinzel(fontSize: 15, color: AppColors.lightGold, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: Ramesh Kumar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
            Text('DOB: 12 May 1994 • 06:45 AM • Chennai', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rasi Chart & Dasha Snapshot:', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.lightGold, fontWeight: FontWeight.bold)),
                  Text('Lagna: Vrishabha • Moon Sign: Rohini (Taurus)\nCurrent Dasha: Rahu Mahadasha - Saturn Antardasha', style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text('Consultation Type: Voice Call (30 Min)', style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Reject / Busy', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Accepted Call! Starting 3-5 min Horoscope Analysis mode.')),
              );
            },
            child: Text('Accept & Analyze', style: GoogleFonts.outfit(color: AppColors.backgroundDeep, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _breakTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = _astrologer.status;

    return Scaffold(
      key: _scaffoldKey,
      drawer: CosmicDrawer(
        onSelectRoute: (route) {
          Navigator.of(context).pop();
          widget.onNavigate(route);
        },
      ),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMid,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.lightGold),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text('Astrologer Dashboard', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_rounded, color: AppColors.lightGold),
            onPressed: _showIncomingCallModal,
          ),
        ],
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Profile Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 28, backgroundImage: NetworkImage(_astrologer.photoUrl)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _astrologer.name,
                              style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${_astrologer.qualification} • ${_astrologer.experienceYears} Yrs Exp',
                              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.lightGold, size: 16),
                                Text(
                                  ' ${_astrologer.rating} (${_astrologer.totalReviews} reviews)',
                                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.lightGold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Status Switcher Buttons (Online, Offline, Break 15m/30m)
                Text('Availability Status', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: status == 'online' ? Colors.green : AppColors.cardSurface,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        onPressed: () => _setStatus('online'),
                        child: const FittedBox(fit: BoxFit.scaleDown, child: Text('Online')),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: status == 'offline' ? Colors.redAccent : AppColors.cardSurface,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        onPressed: () => _setStatus('offline'),
                        child: const FittedBox(fit: BoxFit.scaleDown, child: Text('Offline')),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: status == 'break' ? Colors.orangeAccent : AppColors.cardSurface,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        onPressed: () => _setStatus('break', breakMinutes: 15),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(status == 'break' ? '${_breakSecondsLeft ~/ 60}m Left' : 'Break 15m'),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Call Stats Row
                Row(
                  children: [
                    _buildStatCard('Today\'s Calls', '8 Calls', Icons.phone_callback_rounded),
                    const SizedBox(width: 8),
                    _buildStatCard('Weekly Calls', '42 Calls', Icons.date_range_rounded),
                    const SizedBox(width: 8),
                    _buildStatCard('Monthly Calls', '168 Calls', Icons.calendar_month_rounded),
                  ],
                ),

                const SizedBox(height: 16),

                // Earnings & Platform Commission Breakdown (20%)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundMid,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryGold),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EARNINGS & COMMISSION BREAKDOWN',
                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 12),
                      _buildEarningRow('Total Revenue Earned', '₹${_astrologer.totalEarnings.toStringAsFixed(0)}'),
                      _buildEarningRow('Platform Commission Cut (20%)', '-₹${_astrologer.platformCommission.toStringAsFixed(0)}', isDeduction: true),
                      const Divider(color: Colors.white12),
                      _buildEarningRow('Net Astrologer Earnings (80%)', '₹${_astrologer.netEarnings.toStringAsFixed(0)}', isHighlight: true),
                      const SizedBox(height: 12),

                      // Responsive Payouts Row (Flex/Wrap prevents any horizontal overflow)
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          Text(
                            'Pending Payout: ₹${_astrologer.pendingPayout.toStringAsFixed(0)}',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                          ),
                          Text(
                            'Completed: ₹${_astrologer.completedPayout.toStringAsFixed(0)}',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Astrologer Content Management Section (CMS Quick Access)
                Text(
                  'ASTROLOGER CONTENT CMS TOOLS',
                  style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.lightGold, letterSpacing: 1),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/panchang'),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderGold.withOpacity(0.6)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.edit_calendar_rounded, color: AppColors.lightGold, size: 24),
                              const SizedBox(height: 8),
                              Text('Edit Panchangam', style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text('Tithi, Nakshatra, Rahu Kalam', style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/planet_positions'),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderGold.withOpacity(0.6)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.public_rounded, color: AppColors.lightGold, size: 24),
                              const SizedBox(height: 8),
                              Text('Edit Planet Positions', style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text('Degrees, Rasi & Retrograde', style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String val, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.lightGold, size: 20),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(title, style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(val, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningRow(String label, String value, {bool isDeduction = false, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: isHighlight ? AppColors.lightGold : AppColors.textSecondary,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDeduction ? Colors.redAccent : (isHighlight ? AppColors.lightGold : Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
