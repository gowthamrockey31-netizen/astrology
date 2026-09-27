import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/astrology_calculator.dart';
import '../engine/jamakkol_aspect_calculator.dart';
import '../engine/jamakkol_engine.dart';
import '../models/jamakkol_models.dart';
import '../widgets/jamakkol_chart.dart';
import '../widgets/jamam_status_card.dart';
import '../widgets/planet_position_table.dart';
import '../widgets/udayam_arudam_kavippu_card.dart';
import '../widgets/jamakkol_result_sections.dart';
import 'jamakkol_result_screen.dart';

/// Primary Live Interactive Screen for Jamakkol Prasannam
class JamakkolLiveScreen extends StatefulWidget {
  final JamakkolLocation initialLocation;
  final DateTime? initialDateTime;

  const JamakkolLiveScreen({
    super.key,
    this.initialLocation = JamakkolLocation.defaultChennai,
    this.initialDateTime,
  });

  @override
  State<JamakkolLiveScreen> createState() => _JamakkolLiveScreenState();
}

class _JamakkolLiveScreenState extends State<JamakkolLiveScreen> with WidgetsBindingObserver {
  final GlobalKey _chartRepaintKey = GlobalKey();

  late JamakkolLocation _selectedLocation;
  late DateTime _currentDateTime;
  bool _isLive = true;
  bool _isTamil = true;

  String _question = '';
  JamakkolQuestionCategory _questionCategory = JamakkolQuestionCategory.general;
  int? _customArudamNumber;

  late JamakkolChartState _chartState;
  Timer? _liveTimer;
  int _lastCalculatedMinute = -1;

  // Preset location list
  static const List<JamakkolLocation> presetLocations = [
    JamakkolLocation(name: 'Chennai (சென்னை)', latitude: 13.0827, longitude: 80.2707, timezone: 5.5),
    JamakkolLocation(name: 'Thiruvarur (திருவாரூர்)', latitude: 10.7725, longitude: 79.6365, timezone: 5.5),
    JamakkolLocation(name: 'Madurai (மதுரை)', latitude: 9.9252, longitude: 78.1198, timezone: 5.5),
    JamakkolLocation(name: 'Coimbatore (கோயம்புத்தூர்)', latitude: 11.0168, longitude: 76.9558, timezone: 5.5),
    JamakkolLocation(name: 'Tiruchirappalli (திருச்சி)', latitude: 10.7905, longitude: 78.7047, timezone: 5.5),
    JamakkolLocation(name: 'Salem (சேலம்)', latitude: 11.6643, longitude: 78.1460, timezone: 5.5),
    JamakkolLocation(name: 'Tirunelveli (திருநெல்வேலி)', latitude: 8.7139, longitude: 77.7567, timezone: 5.5),
    JamakkolLocation(name: 'Thanjavur (தஞ்சாவூர்)', latitude: 10.7870, longitude: 79.1378, timezone: 5.5),
    JamakkolLocation(name: 'Kumbakonam (கும்பகோணம்)', latitude: 10.9602, longitude: 79.3845, timezone: 5.5),
    JamakkolLocation(name: 'Bengaluru (பெங்களூரு)', latitude: 12.9716, longitude: 77.5946, timezone: 5.5),
    JamakkolLocation(name: 'Singapore (சிங்கப்பூர்)', latitude: 1.3521, longitude: 103.8198, timezone: 8.0),
    JamakkolLocation(name: 'London (இலண்டன்)', latitude: 51.5074, longitude: -0.1278, timezone: 0.0),
    JamakkolLocation(name: 'New York (நியூயார்க்)', latitude: 40.7128, longitude: -74.0060, timezone: -5.0),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedLocation = widget.initialLocation;
    _currentDateTime = widget.initialDateTime ?? DateTime.now();
    _isLive = widget.initialDateTime == null;

    _recalculateChart();

    if (_isLive) {
      _startLiveTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _liveTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState == AppLifecycleState.resumed && _isLive) {
      // Refresh current time immediately when app resumes from background
      setState(() {
        _currentDateTime = DateTime.now();
        _recalculateChart();
      });
    }
  }

  void _startLiveTimer() {
    _liveTimer?.cancel();
    _liveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isLive) return;
      final now = DateTime.now();

      // Update state: tick time every second; recalculate chart every minute or when second % 10 == 0
      if (mounted) {
        if (now.minute != _lastCalculatedMinute || now.second % 10 == 0) {
          setState(() {
            _currentDateTime = now;
            _recalculateChart();
          });
        } else {
          setState(() {
            _currentDateTime = now;
          });
        }
      }
    });
  }

  void _recalculateChart() {
    try {
      _lastCalculatedMinute = _currentDateTime.minute;
      _chartState = JamakkolEngine.calculateChart(
        queryDateTime: _currentDateTime,
        location: _selectedLocation,
        isLive: _isLive,
        question: _question,
        questionCategory: _questionCategory,
        customArudamNumber: _customArudamNumber,
      );
    } catch (e) {
      debugPrint('Jamakkol Calculation Error: $e');
    }
  }

  void _toggleLiveMode(bool live) {
    setState(() {
      _isLive = live;
      if (_isLive) {
        _currentDateTime = DateTime.now();
        _recalculateChart();
        _startLiveTimer();
      } else {
        _liveTimer?.cancel();
      }
    });
  }

  Future<void> _selectManualDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _currentDateTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFD700),
              onPrimary: Colors.black,
              surface: Color(0xFF0F172A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_currentDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFFFD700),
                onPrimary: Colors.black,
                surface: Color(0xFF0F172A),
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _isLive = false;
          _liveTimer?.cancel();
          _currentDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _recalculateChart();
        });
      }
    }
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: Color(0xFFFFD700)),
                    const SizedBox(width: 8),
                    Text(
                      _isTamil ? 'இடத்தைத் தேர்ந்தெடுக்கவும்' : 'Select Location',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12),
              Expanded(
                child: ListView.builder(
                  itemCount: presetLocations.length,
                  itemBuilder: (ctx, idx) {
                    final loc = presetLocations[idx];
                    final isSelected = loc.name == _selectedLocation.name;
                    return ListTile(
                      title: Text(
                        loc.name,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFFFFD700) : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        'Lat: ${loc.latitude}°, Lon: ${loc.longitude}° (UTC+${loc.timezone})',
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFFFFD700)) : null,
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _selectedLocation = loc;
                          _recalculateChart();
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showArudamSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isTamil ? 'ஆருடம் தேர்வு முறை' : 'Arudam Selection Mode',
                  style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.access_time_rounded, color: Color(0xFF10B981)),
                  title: Text(
                    _isTamil ? 'கடிகார நேர ஆருடம் (Time-based Arudam)' : 'Time-based Minute Arudam',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _isTamil ? 'தற்போதைய நிமிடத்தின் அடிப்படையில் (6° / நிமிடம்)' : 'Rotates 6° per minute continuously',
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                  selected: _customArudamNumber == null,
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _customArudamNumber = null;
                      _recalculateChart();
                    });
                  },
                ),
                const Divider(color: Colors.white12),
                Text(
                  _isTamil ? 'அல்லது குறிப்பிட்ட ஆருட எண் (1 முதல் 12):' : 'Or select fixed Arudam sign (1..12):',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(12, (i) {
                    final num = i + 1;
                    final isSel = _customArudamNumber == num;
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _customArudamNumber = num;
                          _recalculateChart();
                        });
                      },
                      child: Container(
                        width: 44,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFFFD700) : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSel ? const Color(0xFFFFD700) : Colors.white24),
                        ),
                        child: Center(
                          child: Text(
                            '$num',
                            style: TextStyle(
                              color: isSel ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRasiDetailSheet(int rasiIndex) {
    final rasiName = _isTamil ? AstrologyCalculator.rasiNamesTa[rasiIndex] : AstrologyCalculator.rasiNamesEn[rasiIndex];
    final houseNum = (((rasiIndex - _chartState.udayam.rasiIndex) % 12 + 12) % 12) + 1;
    final rasiLord = _isTamil ? JamakkolAspectCalculator.rasiLordsTa[rasiIndex] : JamakkolAspectCalculator.rasiLordsEn[rasiIndex];

    final gocharamPlanets = _chartState.transitPlanetsByRasi[rasiIndex] ?? [];
    final jamamPlanets = _chartState.jamakkolPlanetsByRasi[rasiIndex] ?? [];
    final specialPoints = _chartState.specialPointsByRasi[rasiIndex] ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          rasiName,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isTamil ? 'உதயத்திலிருந்து $houseNum-ஆம் பாவம்' : 'House $houseNum from Udayam',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const Spacer(),
                      Text(
                        '${_isTamil ? "அதிபதி" : "Lord"}: $rasiLord',
                        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Special points in this sign
                  if (specialPoints.isNotEmpty) ...[
                    Text(
                      _isTamil ? 'முக்கிய புள்ளிகள் / உபகிரகங்கள்:' : 'Special Points in Sign:',
                      style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    ...specialPoints.map((pt) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '• ${pt.nameTa} (${pt.shortCode}) - ${pt.formattedDms} (★ ${pt.nakshatraTa}-${pt.pada})',
                            style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                          ),
                        )),
                    const SizedBox(height: 10),
                  ],

                  // Gocharam planets in this sign
                  if (gocharamPlanets.isNotEmpty) ...[
                    Text(
                      _isTamil ? 'கோச்சார கிரகங்கள்:' : 'Transit Planets:',
                      style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    ...gocharamPlanets.map((tp) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '• ${tp.nameTa} - ${tp.formattedDms} (★ ${tp.nakshatraTa}-${tp.pada}) [${tp.dignityLabelTa}]',
                            style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                          ),
                        )),
                    const SizedBox(height: 10),
                  ],

                  // Jamakkol planets in this sign
                  if (jamamPlanets.isNotEmpty) ...[
                    Text(
                      _isTamil ? 'ஜாம கிரகங்கள் (வெளி வட்டம்):' : 'Jamam Planets (Outer Ring):',
                      style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    ...jamamPlanets.map((jp) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '• ஜாம ${jp.nameTa} - ${jp.formattedDms} (★ ${jp.nakshatraTa}-${jp.pada}) ${jp.isCurrentJamamLord ? "[நடப்பு ஜாம அதிபதி]" : ""}',
                            style: TextStyle(
                              color: jp.isCurrentJamamLord ? const Color(0xFFFFD700) : Colors.white70,
                              fontWeight: jp.isCurrentJamamLord ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12.5,
                            ),
                          ),
                        )),
                  ],

                  if (specialPoints.isEmpty && gocharamPlanets.isEmpty && jamamPlanets.isEmpty)
                    Text(
                      _isTamil ? 'இந்த ராசியில் கிரகங்கள் அல்லது சிறப்பு புள்ளிகள் இல்லை' : 'No planets or points in this sign',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 2,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isTamil ? 'ஜாமக்கோள் பிரசன்னம்' : 'Jamakkol Prasannam',
              style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '${_selectedLocation.name} • ${_formatHeaderTime(_currentDateTime)}',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        actions: [
          // Language toggle
          IconButton(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFFD700)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _isTamil ? 'ENG' : 'தமிழ்',
                style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
            onPressed: () => setState(() => _isTamil = !_isTamil),
            tooltip: 'Language Toggle',
          ),

          // Arudam selector
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Color(0xFFFFD700)),
            onPressed: _showArudamSelector,
            tooltip: 'Arudam Settings',
          ),

          // Full report view
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JamakkolResultScreen(state: _chartState, isTamil: _isTamil),
                ),
              );
            },
            tooltip: 'Full Result View',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _currentDateTime = DateTime.now();
            _recalculateChart();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Action Bar: Location, Date/Time picker, LIVE NOW button
              _buildTopControls(),
              const SizedBox(height: 12),

              // 1. Current Jamam Status Card
              JamamStatusCardWidget(state: _chartState, isTamil: _isTamil),
              const SizedBox(height: 12),

              // 2. Three Core Pillars (Udayam, Arudam, Kavippu)
              UdayamArudamKavippuCardWidget(state: _chartState, isTamil: _isTamil),
              const SizedBox(height: 12),

              // 3. Interactive South Indian Jamakkol Chart
              RepaintBoundary(
                key: _chartRepaintKey,
                child: JamakkolChartWidget(
                  state: _chartState,
                  isTamil: _isTamil,
                  onRasiTap: _showRasiDetailSheet,
                ),
              ),
              const SizedBox(height: 12),

              // 4. Planetary Positions Table (Transit, Jamam, Special Points)
              PlanetPositionTableWidget(state: _chartState, isTamil: _isTamil),
              const SizedBox(height: 12),

              // 5. Result Sections: Question input, Verdict, Combinations, Aspects, Next 1 Hour, Remedies
              JamakkolResultSectionsWidget(
                state: _chartState,
                isTamil: _isTamil,
                onQuestionChanged: (q, cat) {
                  setState(() {
                    _question = q;
                    _questionCategory = cat;
                    _recalculateChart();
                  });
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          // Location Button
          Expanded(
            child: InkWell(
              onTap: _showLocationPicker,
              borderRadius: BorderRadius.circular(6),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: Color(0xFFFFD700), size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _selectedLocation.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Date / Time Button
          InkWell(
            onTap: _selectManualDate,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _formatShortDateTime(_currentDateTime),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // LIVE NOW Toggle Button
          InkWell(
            onTap: () => _toggleLiveMode(!_isLive),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isLive ? const Color(0xFF10B981) : const Color(0xFF334155),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _isLive ? 'LIVE' : 'SET LIVE',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatHeaderTime(DateTime dt) {
    final hr = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final sec = dt.second.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hr:$min:$sec $amPm';
  }

  String _formatShortDateTime(DateTime dt) {
    final hr = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day}/${dt.month} $hr:$min $amPm';
  }
}
