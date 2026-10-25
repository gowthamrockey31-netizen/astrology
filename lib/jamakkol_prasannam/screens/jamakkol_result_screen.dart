import 'package:flutter/material.dart';
import '../models/jamakkol_models.dart';
import '../widgets/jamakkol_chart.dart';
import '../widgets/planet_position_table.dart';
import '../widgets/udayam_arudam_kavippu_card.dart';

/// Full-screen printable / shareable consultation report for Jamakkol Prasannam
class JamakkolResultScreen extends StatelessWidget {
  final JamakkolChartState state;
  final bool isTamil;

  const JamakkolResultScreen({
    super.key,
    required this.state,
    this.isTamil = true,
  });

  @override
  Widget build(BuildContext context) {
    final interp = state.interpretation;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(
          isTamil ? 'பிரசன்ன ஆய்வு அறிக்கை' : 'Prasannam Consultation Report',
          style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Color(0xFFFFD700)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isTamil ? 'பிரசன்ன அறிக்கை பகிர தயாராக உள்ளது.' : 'Prasannam report ready to share.',
                  ),
                  backgroundColor: const Color(0xFF1E293B),
                ),
              );
            },
            tooltip: 'Share Report',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            14,
            14,
            14,
            MediaQuery.of(context).padding.bottom + 36,
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Report Header Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: Color(0xFFFFD700), size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isTamil ? 'ஜாமக்கோள் பிரசன்ன ஆய்வு' : 'Jamakkol Prasannam Analysis',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${isTamil ? "நேரம்" : "Time"}: ${_formatFullDateTime(state.queryDateTime)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${isTamil ? "இடம்" : "Location"}: ${state.location.name} (${state.location.latitude}°, ${state.location.longitude}°)',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${isTamil ? "மாதம்" : "Month"}: ${state.tamilMonth} • ${isTamil ? "ஜாமம்" : "Jamam"}: ${state.currentJamam.displayNameTa} (${isTamil ? "அதிபதி" : "Lord"}: ${state.currentJamam.rulingPlanetTa})',
                    style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Inquired Question Card
            if (state.question.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.help_rounded, color: Color(0xFFFFD700), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTamil ? 'கேட்கப்பட்ட கேள்வி:' : 'Inquired Question:',
                            style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '"${state.question}"',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 1. Verdict Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: interp.isOverallFavorable
                    ? const Color(0xFF065F46).withValues(alpha: 0.3)
                    : const Color(0xFF7F1D1D).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: interp.isOverallFavorable ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        interp.isOverallFavorable ? Icons.check_circle : Icons.warning_amber,
                        color: interp.isOverallFavorable ? const Color(0xFF34D399) : const Color(0xFFF87171),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isTamil ? interp.verdictTitleTa : interp.verdictTitleEn,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      Text(
                        '${interp.confidenceScore}% அனுகூலம்',
                        style: TextStyle(
                          color: interp.isOverallFavorable ? const Color(0xFF34D399) : const Color(0xFFF87171),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isTamil ? interp.verdictSummaryTa : interp.verdictSummaryEn,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isTamil ? interp.questionAnalysisTa : interp.questionAnalysisEn,
                    style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. Three Pillars Card
            UdayamArudamKavippuCardWidget(state: state, isTamil: isTamil),
            const SizedBox(height: 12),

            // 3. Compact Chart
            JamakkolChartWidget(state: state, isTamil: isTamil),
            const SizedBox(height: 12),

            // 4. Planetary Position Tables
            PlanetPositionTableWidget(state: state, isTamil: isTamil),
            const SizedBox(height: 12),

            // 5. Remedies / Practical Guidance
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.temple_hindu_rounded, color: Color(0xFFFFD700), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isTamil ? 'ஜோதிடப் பரிகாரம் & வழிகாட்டல்' : 'Remedy & Spiritual Guidance',
                          style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isTamil ? interp.practicalRemedyTa : interp.practicalRemedyEn,
                    style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      ),
    );
  }

  String _formatFullDateTime(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final mStr = months[dt.month - 1];
    final hr = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final sec = dt.second.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} $mStr ${dt.year} $hr:$min:$sec $amPm';
  }
}
