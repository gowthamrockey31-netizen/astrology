import 'package:flutter/material.dart';
import '../models/jamakkol_models.dart';
import '../models/jamakkol_planet_models.dart';

/// Table displaying detailed positions of Transit Planets, Jamakkol Planets, and Special Points
class PlanetPositionTableWidget extends StatefulWidget {
  final JamakkolChartState state;
  final bool isTamil;

  const PlanetPositionTableWidget({
    super.key,
    required this.state,
    this.isTamil = true,
  });

  @override
  State<PlanetPositionTableWidget> createState() => _PlanetPositionTableWidgetState();
}

class _PlanetPositionTableWidgetState extends State<PlanetPositionTableWidget> {
  int _selectedTabIndex = 0; // 0: Gocharam, 1: Jamam, 2: Special Points

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Tab Switcher
          Row(
            children: [
              const Icon(Icons.table_chart_rounded, color: Color(0xFFFFD700), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.isTamil ? 'கிரக நிலைகள் & பாகைகள்' : 'Planetary Positions & Degrees',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabButton(
                  index: 0,
                  label: widget.isTamil ? 'கோச்சார கிரகங்கள்' : 'Transit Planets',
                  badgeCount: widget.state.transitPlanets.length,
                ),
                const SizedBox(width: 8),
                _buildTabButton(
                  index: 1,
                  label: widget.isTamil ? 'ஜாம கிரகங்கள் (8)' : 'Jamam Planets (8)',
                  badgeCount: widget.state.jamakkolPlanets.length,
                ),
                const SizedBox(width: 8),
                _buildTabButton(
                  index: 2,
                  label: widget.isTamil ? 'சிறப்பு புள்ளிகள்' : 'Special Points',
                  badgeCount: widget.state.upagrahas.length + 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Table Content
          if (_selectedTabIndex == 0)
            _buildTransitPlanetsTable()
          else if (_selectedTabIndex == 1)
            _buildJamakkolPlanetsTable()
          else
            _buildSpecialPointsTable(),
        ],
      ),
    );
  }

  Widget _buildTabButton({required int index, required String label, required int badgeCount}) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD700) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black.withValues(alpha: 0.15) : Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badgeCount',
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gocharam Transit Planets Table
  Widget _buildTransitPlanetsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFF1E293B)),
        dataRowMinHeight: 38,
        dataRowMaxHeight: 44,
        columnSpacing: 16,
        horizontalMargin: 8,
        columns: [
          DataColumn(label: Text(widget.isTamil ? 'கிரகம்' : 'Planet', style: _headerStyle)),
          DataColumn(label: Text(widget.isTamil ? 'ராசி' : 'Rasi', style: _headerStyle)),
          DataColumn(label: Text(widget.isTamil ? 'பாகை' : 'Degree', style: _headerStyle)),
          DataColumn(label: Text(widget.isTamil ? 'நட்சத்திரம்' : 'Nakshatra', style: _headerStyle)),
          DataColumn(label: Text(widget.isTamil ? 'பாதம்' : 'Pada', style: _headerStyle)),
          DataColumn(label: Text(widget.isTamil ? 'நிலை' : 'Status', style: _headerStyle)),
        ],
        rows: widget.state.transitPlanets.map((tp) {
          return DataRow(cells: [
            DataCell(Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isTamil ? tp.nameTa : tp.nameEn,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                if (tp.isRetrograde) ...[
                  const SizedBox(width: 4),
                  _buildStatusChip('வக்ரம்', const Color(0xFFEF4444)),
                ],
                if (tp.isCombust) ...[
                  const SizedBox(width: 4),
                  _buildStatusChip('அஸ்தங்கம்', const Color(0xFFF97316)),
                ],
              ],
            )),
            DataCell(Text(widget.isTamil ? tp.rasiNameTa : tp.rasiNameEn, style: _dataStyle)),
            DataCell(Text(tp.formattedDms, style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w600, fontSize: 12))),
            DataCell(Text(widget.isTamil ? tp.nakshatraTa : tp.nakshatraEn, style: _dataStyle)),
            DataCell(Text('${tp.pada}', style: _dataStyle)),
            DataCell(_buildDignityChip(tp)),
          ]);
        }).toList(),
      ),
    );
  }

  /// Jamakkol 8 Outer Planets Table
  Widget _buildJamakkolPlanetsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFF1E293B)),
        dataRowMinHeight: 38,
        dataRowMaxHeight: 44,
        columnSpacing: 16,
        horizontalMargin: 8,
        columns: [
          DataColumn(label: Text(widget.isTamil ? 'ஜாம கிரகம்' : 'Jamam Planet', style: _headerStyle)),
          DataColumn(label: Text(widget.isTamil ? 'ராசி' : 'Rasi', style: _headerStyle)),
          DataColumn(label: Text(widget.isTamil ? 'பாகை' : 'Degree', style: _headerStyle)),
          DataColumn(label: Text(widget.isTamil ? 'நட்சத்திரம்' : 'Nakshatra', style: _headerStyle)),
          DataColumn(label: Text(widget.isTamil ? 'பாதம்' : 'Pada', style: _headerStyle)),
          DataColumn(label: Text(widget.isTamil ? 'அதிபதி' : 'Role', style: _headerStyle)),
        ],
        rows: widget.state.jamakkolPlanets.map((jp) {
          final isLord = jp.isCurrentJamamLord;
          return DataRow(
            color: isLord ? WidgetStateProperty.all(const Color(0xFFF59E0B).withValues(alpha: 0.12)) : null,
            cells: [
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.isTamil ? jp.nameTa : jp.nameEn,
                    style: TextStyle(
                      color: isLord ? const Color(0xFFFFD700) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  if (isLord) ...[
                    const SizedBox(width: 6),
                    _buildStatusChip('ஜாம அதிபதி', const Color(0xFFF59E0B)),
                  ],
                ],
              )),
              DataCell(Text(widget.isTamil ? jp.rasiNameTa : jp.rasiNameEn, style: _dataStyle)),
              DataCell(Text(jp.formattedDms, style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w600, fontSize: 12))),
              DataCell(Text(widget.isTamil ? jp.nakshatraTa : jp.nakshatraEn, style: _dataStyle)),
              DataCell(Text('${jp.pada}', style: _dataStyle)),
              DataCell(Text(
                isLord ? (widget.isTamil ? 'தற்போதைய ஜாம அதிபதி' : 'Current Jamam Lord') : '-',
                style: TextStyle(
                  color: isLord ? const Color(0xFFFFD700) : Colors.white38,
                  fontSize: 11,
                  fontWeight: isLord ? FontWeight.bold : FontWeight.normal,
                ),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Special Points & Upagrahas Table
  Widget _buildSpecialPointsTable() {
    final List<JamakkolSpecialPoint> allPoints = [
      widget.state.udayam,
      widget.state.arudam,
      widget.state.kavippu,
      ...widget.state.upagrahas,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFF1E293B)),
        dataRowMinHeight: 38,
        dataRowMaxHeight: 44,
        columnSpacing: 16,
        horizontalMargin: 8,
        columns: [
          DataColumn(label: Text(widget.isTamil ? 'புள்ளி' : 'Point', style: _headerStyle)),
          DataColumn(label: Text(widget.isTamil ? 'குறியீடு' : 'Code', style: _headerStyle)),
          DataColumn(label: Text(widget.isTamil ? 'ராசி' : 'Rasi', style: _headerStyle)),
          DataColumn(label: Text(widget.isTamil ? 'பாகை' : 'Degree', style: _headerStyle)),
          DataColumn(label: Text(widget.isTamil ? 'பாவம்' : 'House', style: _headerStyle)),
          DataColumn(label: Text(widget.isTamil ? 'நட்சத்திரம்' : 'Star & Pada', style: _headerStyle)),
        ],
        rows: allPoints.map((pt) {
          Color pointColor = Colors.white;
          if (pt.type == SpecialPointType.udayam) pointColor = const Color(0xFF60A5FA);
          if (pt.type == SpecialPointType.arudam) pointColor = const Color(0xFF34D399);
          if (pt.type == SpecialPointType.kavippu) pointColor = const Color(0xFFF87171);
          if (pt.type == SpecialPointType.mandi) pointColor = const Color(0xFFF472B6);
          if (pt.type == SpecialPointType.rahuKaalam) pointColor = const Color(0xFFC084FC);
          if (pt.type == SpecialPointType.yamakandam) pointColor = const Color(0xFFFB923C);
          if (pt.type == SpecialPointType.mrityu) pointColor = const Color(0xFFFB7185);
          if (pt.type == SpecialPointType.lagna) pointColor = const Color(0xFF38BDF8);

          return DataRow(cells: [
            DataCell(Text(
              widget.isTamil ? pt.nameTa : pt.nameEn,
              style: TextStyle(color: pointColor, fontWeight: FontWeight.bold, fontSize: 13),
            )),
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: pointColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(pt.shortCode, style: TextStyle(color: pointColor, fontWeight: FontWeight.bold, fontSize: 11)),
            )),
            DataCell(Text(widget.isTamil ? pt.rasiNameTa : pt.rasiNameEn, style: _dataStyle)),
            DataCell(Text(pt.formattedDms, style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w600, fontSize: 12))),
            DataCell(Text('${pt.houseFromUdayam}-ஆம் இடம்', style: _dataStyle)),
            DataCell(Text('${widget.isTamil ? pt.nakshatraTa : pt.nakshatraEn} - ${pt.pada}', style: _dataStyle)),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildDignityChip(TransitPlanet tp) {
    Color bg = const Color(0xFF334155);
    Color txt = Colors.white70;

    switch (tp.dignity) {
      case PlanetaryDignity.exalted:
        bg = const Color(0xFF15803D);
        txt = Colors.white;
        break;
      case PlanetaryDignity.ownSign:
        bg = const Color(0xFF0369A1);
        txt = Colors.white;
        break;
      case PlanetaryDignity.debilitated:
        bg = const Color(0xFFB91C1C);
        txt = Colors.white;
        break;
      case PlanetaryDignity.combust:
        bg = const Color(0xFFC2410C);
        txt = Colors.white;
        break;
      default:
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.isTamil ? tp.dignityLabelTa : tp.dignityLabelEn,
        style: TextStyle(color: txt, fontSize: 10.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color, width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  static const _headerStyle = TextStyle(
    color: Color(0xFFFFD700),
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  static const _dataStyle = TextStyle(
    color: Colors.white70,
    fontSize: 12,
  );
}
