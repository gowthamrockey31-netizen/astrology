import 'package:flutter/material.dart';
import '../models/jamakkol_models.dart';
import '../models/jamam_models.dart';

/// Status card displaying current Jamam details, timing progress, sunrise/sunset, and expandable 16-Jamam schedule
class JamamStatusCardWidget extends StatefulWidget {
  final JamakkolChartState state;
  final bool isTamil;

  const JamamStatusCardWidget({
    super.key,
    required this.state,
    this.isTamil = true,
  });

  @override
  State<JamamStatusCardWidget> createState() => _JamamStatusCardWidgetState();
}

class _JamamStatusCardWidgetState extends State<JamamStatusCardWidget> {
  bool _isScheduleExpanded = false;

  @override
  Widget build(BuildContext context) {
    final jamam = widget.state.currentJamam;
    final schedule = widget.state.jamamSchedule;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Live indicator & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.state.isLive ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.state.isLive) ...[
                      const Icon(Icons.circle, size: 8, color: Colors.white),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      widget.state.isLive ? 'LIVE NOW' : 'MANUAL TIME',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                widget.isTamil
                    ? '${schedule.weekdayNameTa} (${schedule.dayLordTa} ஆதிக்கம்)'
                    : '${schedule.weekdayNameEn} (${schedule.dayLordEn} Day)',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Jamam Info Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Jamam Number Big Badge
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '#${jamam.periodIndex}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        jamam.isDay ? (widget.isTamil ? 'பகல்' : 'Day') : (widget.isTamil ? 'இரவு' : 'Night'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Jamam Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isTamil
                          ? '${jamam.periodLabelTa} #${jamam.periodIndex} (மொத்தம் #${jamam.number})'
                          : '${jamam.periodLabelEn} #${jamam.periodIndex} (Overall #${jamam.number})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          widget.isTamil ? 'ஜாம அதிபதி: ' : 'Ruling Planet: ',
                          style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFFFD700), width: 0.8),
                          ),
                          child: Text(
                            widget.isTamil ? jamam.rulingPlanetTa : jamam.rulingPlanetEn,
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_formatTime(jamam.startTime)} - ${_formatTime(jamam.endTime)} (${jamam.durationMinutes.toStringAsFixed(0)} நிமிடம்)',
                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11.5, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Elapsed and Remaining Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isTamil
                        ? 'சென்றது: ${jamam.elapsedMinutes.toStringAsFixed(0)} நிமிடம்'
                        : 'Elapsed: ${jamam.elapsedMinutes.toStringAsFixed(0)} mins',
                    style: const TextStyle(color: Colors.white60, fontSize: 10.5),
                  ),
                  Text(
                    widget.isTamil
                        ? 'மீதம்: ${jamam.remainingMinutes.toStringAsFixed(0)} நிமிடம்'
                        : 'Remaining: ${jamam.remainingMinutes.toStringAsFixed(0)} mins',
                    style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: jamam.progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF334155),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sunrise and Sunset Info Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0B132B).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSunInfo(
                  icon: Icons.wb_sunny_rounded,
                  label: widget.isTamil ? 'சூரிய உதயம்' : 'Sunrise',
                  time: _formatTime(schedule.sunrise),
                  color: const Color(0xFFF59E0B),
                ),
                Container(width: 1, height: 24, color: Colors.white12),
                _buildSunInfo(
                  icon: Icons.nightlight_round,
                  label: widget.isTamil ? 'சூரிய அஸ்தமனம்' : 'Sunset',
                  time: _formatTime(schedule.sunset),
                  color: const Color(0xFF818CF8),
                ),
                Container(width: 1, height: 24, color: Colors.white12),
                _buildSunInfo(
                  icon: Icons.timelapse_rounded,
                  label: widget.isTamil ? 'பகல் / இரவு அளவு' : 'Day / Night',
                  time: '${(schedule.dayDurationMinutes / 60.0).toStringAsFixed(1)}h / ${(schedule.nightDurationMinutes / 60.0).toStringAsFixed(1)}h',
                  color: const Color(0xFF34D399),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Toggle Expand 16-Jamam Schedule
          InkWell(
            onTap: () => setState(() => _isScheduleExpanded = !_isScheduleExpanded),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isScheduleExpanded
                        ? (widget.isTamil ? '16 ஜாம அட்டவணையை மறைக்கவும்' : 'Hide 16-Jamam Schedule')
                        : (widget.isTamil ? 'அனைத்து 16 ஜாம அட்டவணையை விரித்து பார்க்க' : 'View Full 16-Jamam Schedule'),
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    _isScheduleExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFFFFD700),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Expandable 16 Jamam List
          if (_isScheduleExpanded) ...[
            const Divider(color: Colors.white12, height: 16),
            _buildScheduleTable(schedule),
          ],
        ],
      ),
    );
  }

  Widget _buildSunInfo({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 2),
        Text(time, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildScheduleTable(JamamDaySchedule schedule) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFF1E293B)),
        dataRowMinHeight: 32,
        dataRowMaxHeight: 38,
        columnSpacing: 16,
        horizontalMargin: 8,
        columns: [
          DataColumn(label: Text(widget.isTamil ? 'எண்' : '#', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold))),
          DataColumn(label: Text(widget.isTamil ? 'வகை' : 'Type', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold))),
          DataColumn(label: Text(widget.isTamil ? 'அதிபதி' : 'Lord', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold))),
          DataColumn(label: Text(widget.isTamil ? 'தொடக்கம்' : 'Start', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold))),
          DataColumn(label: Text(widget.isTamil ? 'முடிவு' : 'End', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold))),
          DataColumn(label: Text(widget.isTamil ? 'நிலை' : 'Status', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold))),
        ],
        rows: schedule.allJamams.map((j) {
          final isCurrent = j.number == widget.state.currentJamam.number;
          return DataRow(
            color: isCurrent ? WidgetStateProperty.all(const Color(0xFFF59E0B).withValues(alpha: 0.2)) : null,
            cells: [
              DataCell(Text('#${j.number}', style: TextStyle(color: isCurrent ? const Color(0xFFFFD700) : Colors.white, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal, fontSize: 11.5))),
              DataCell(Text(j.isDay ? (widget.isTamil ? 'பகல் #${j.periodIndex}' : 'Day #${j.periodIndex}') : (widget.isTamil ? 'இரவு #${j.periodIndex}' : 'Night #${j.periodIndex}'), style: const TextStyle(color: Colors.white70, fontSize: 11))),
              DataCell(Text(widget.isTamil ? j.rulingPlanetTa : j.rulingPlanetEn, style: TextStyle(color: isCurrent ? const Color(0xFFFFD700) : Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5))),
              DataCell(Text(_formatTime(j.startTime), style: const TextStyle(color: Colors.white70, fontSize: 11))),
              DataCell(Text(_formatTime(j.endTime), style: const TextStyle(color: Colors.white70, fontSize: 11))),
              DataCell(isCurrent
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        widget.isTamil ? 'நடப்பு' : 'Active',
                        style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                      ),
                    )
                  : const Text('-', style: TextStyle(color: Colors.white24, fontSize: 11))),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hr = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hr:$min $amPm';
  }
}
