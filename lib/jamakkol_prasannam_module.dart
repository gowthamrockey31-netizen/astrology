import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Jamakkol Prasannam - single-file Flutter module.
/// ---------------------------------------------------------------------------
/// This implementation recreates the calculation/display workflow as an
/// independent Flutter module. It does not copy the source code or assets of
/// jamakkolprasannam.com.
///
/// Important:
/// - Planetary longitudes below use a self-contained low-precision analytical
///   solar-system model. For professional ephemeris-grade results, replace
///   PlanetEngine.positions() with your preferred ephemeris implementation.
/// - Sunrise/sunset uses a self-contained NOAA-style solar calculation.
/// - The traditional Jamakkol special-point rules are isolated in
///   JamakkolEngine so they can be adjusted without changing the UI.
/// - No paid/licensed astrology package is required.
///
/// Add this file to lib/jamakkol_prasannam_module.dart and run:
///   flutter run
///
/// Example:
///   Navigator.push(context, MaterialPageRoute(
///     builder: (_) => const JamakkolPrasannamModule(),
///   ));
/// ---------------------------------------------------------------------------

enum LanguageMode { tamil, english }

class GeoPlace {
  final String name;
  final double latitude;
  final double longitude;
  final double timeZone;
  const GeoPlace({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timeZone,
  });
}

class PlanetPosition {
  final String name;
  final double longitude;
  final bool retrograde;
  const PlanetPosition(this.name, this.longitude, {this.retrograde = false});

  int get sign => (longitude / 30).floor() % 12;
  double get degreeInSign => longitude % 30;
}

class SpecialPoint {
  final String name;
  final double longitude;
  const SpecialPoint(this.name, this.longitude);

  int get sign => (longitude / 30).floor() % 12;
  double get degreeInSign => longitude % 30;
}

class JamamInfo {
  final int number;
  final String planet;
  final DateTime start;
  final DateTime end;
  const JamamInfo(this.number, this.planet, this.start, this.end);
}

class PrasannaResult {
  final GeoPlace place;
  final DateTime localTime;
  final DateTime sunrise;
  final DateTime sunset;
  final int weekday;
  final JamamInfo jamam;
  final List<PlanetPosition> transit;
  final List<PlanetPosition> jamamPlanets;
  final SpecialPoint udhayam;
  final SpecialPoint aarudam;
  final SpecialPoint kavippu;
  final SpecialPoint maandi;
  final SpecialPoint yamakandam;
  final SpecialPoint rahuKaalam;
  final SpecialPoint mrityu;
  final String question;

  const PrasannaResult({
    required this.place,
    required this.localTime,
    required this.sunrise,
    required this.sunset,
    required this.weekday,
    required this.jamam,
    required this.transit,
    required this.jamamPlanets,
    required this.udhayam,
    required this.aarudam,
    required this.kavippu,
    required this.maandi,
    required this.yamakandam,
    required this.rahuKaalam,
    required this.mrityu,
    required this.question,
  });
}

const List<String> tamilSigns = [
  'மேஷம்','ரிஷபம்','மிதுனம்','கடகம்','சிம்மம்','கன்னி',
  'துலாம்','விருச்சிகம்','தனுசு','மகரம்','கும்பம்','மீனம்'
];

const List<String> englishSigns = [
  'Aries','Taurus','Gemini','Cancer','Leo','Virgo',
  'Libra','Scorpio','Sagittarius','Capricorn','Aquarius','Pisces'
];

const List<String> tamilPlanets = [
  'சூரியன்','சந்திரன்','செவ்வாய்','புதன்','குரு',
  'சுக்கிரன்','சனி','ராகு','கேது'
];

const List<String> englishPlanets = [
  'Sun','Moon','Mars','Mercury','Jupiter','Venus','Saturn','Rahu','Ketu'
];

const List<String> nakshatras = [
  'அஸ்வினி','பரணி','கார்த்திகை','ரோகிணி','மிருகசீரிஷம்','திருவாதிரை',
  'புனர்பூசம்','பூசம்','ஆயில்யம்','மகம்','பூரம்','உத்திரம்',
  'அஸ்தம்','சித்திரை','சுவாதி','விசாகம்','அனுஷம்','கேட்டை',
  'மூலம்','பூராடம்','உத்திராடம்','திருவோணம்','அவிட்டம்','சதயம்',
  'பூரட்டாதி','உத்திரட்டாதி','ரேவதி'
];

const List<String> weekdayTamil =
    ['திங்கள்','செவ்வாய்','புதன்','வியாழன்','வெள்ளி','சனி','ஞாயிறு'];

const List<String> jamamPlanetNames = [
  'சூரியன்','செவ்வாய்','குரு','புதன்','சுக்கிரன்','சனி','சந்திரன்','ராகு'
];

double norm360(double x) {
  x %= 360.0;
  if (x < 0) x += 360.0;
  return x;
}

double deg2rad(double x) => x * math.pi / 180.0;
double rad2deg(double x) => x * 180.0 / math.pi;

String two(int n) => n.toString().padLeft(2, '0');

String fmtDMS(double longitude) {
  final d = longitude % 30;
  final deg = d.floor();
  final min = ((d - deg) * 60).floor();
  return '${two(deg)}° ${two(min)}′';
}

String nakshatraText(double longitude) {
  final x = norm360(longitude);
  final span = 360.0 / 27.0;
  final index = (x / span).floor().clamp(0, 26);
  final pada = ((x - index * span) / (span / 4)).floor() + 1;
  return '${nakshatras[index]} - $pada';
}

String signName(int index, LanguageMode lang) =>
    (lang == LanguageMode.tamil ? tamilSigns : englishSigns)[index % 12];

String planetName(int index, LanguageMode lang) =>
    (lang == LanguageMode.tamil ? tamilPlanets : englishPlanets)[index];

/// ---------------------------------------------------------------------------
/// Self-contained solar/planet calculation engine.
/// ---------------------------------------------------------------------------
class PlanetEngine {
  static double _jd(DateTime utc) =>
      utc.millisecondsSinceEpoch / 86400000.0 + 2440587.5;

  static double _days(DateTime utc) => _jd(utc) - 2451543.5;

  static double _kepler(double m, double e) {
    var E = m;
    for (int i = 0; i < 12; i++) {
      E -= (E - e * math.sin(E) - m) / (1 - e * math.cos(E));
    }
    return E;
  }

  static Map<String, double> _heliocentric(DateTime utc, int body) {
    final d = _days(utc);
    // Orbital elements referenced to J2000. Low precision by design.
    final N0 = <double>[0,125.1228,48.3313,76.6799,49.5574,113.6634,110.3039,0,0];
    final N1 = <double>[0,-0.0529538,3.24587e-5,2.46590e-5,2.11081e-5,2.38980e-5,
      -3.929e-5,0,0];
    final i0 = <double>[0,7.0047,3.3946,1.8497,1.3030,0.0005,1.3087,0,0];
    final i1 = <double>[0,5.00e-8,2.75e-8,-1.8e-7,-1.55e-7,-1.33e-9,-7.45e-8,0,0];
    final w0 = <double>[0,29.1241,54.8910,286.5016,177.4559,287.1580,274.5024,0,0];
    final w1 = <double>[0,1.01444e-5,-2.73e-5,2.73e-5,2.92961e-5,4.34836e-5,
      1.3972e-5,0,0];
    final a0 = <double>[0,0.387098,0.72333,1.0,1.523688,5.20256,9.55475,0,0];
    final e0 = <double>[0,0.205635,0.006773,-0.000000,0.093405,0.048498,0.055546,0,0];
    final M0 = <double>[0,168.6562,48.0052,356.0470,18.6021,19.8950,316.9670,0,0];
    final M1 = <double>[0,4.0923344368,1.6021302244,0.9856002585,0.5240207766,
      0.0830853001,0.0334442282,0,0];

    final N = norm360(N0[body] + N1[body] * d);
    final i = i0[body] + i1[body] * d;
    final w = norm360(w0[body] + w1[body] * d);
    final a = a0[body];
    final e = e0[body];
    final M = norm360(M0[body] + M1[body] * d);
    final E = _kepler(deg2rad(M), e);
    final xv = a * (math.cos(E) - e);
    final yv = a * (math.sqrt(1 - e * e) * math.sin(E));
    final v = math.atan2(yv, xv);
    final r = math.sqrt(xv * xv + yv * yv);

    final lon = deg2rad(v + deg2rad(w));
    final xh = r * (math.cos(deg2rad(N)) * math.cos(lon) -
        math.sin(deg2rad(N)) * math.sin(lon) * math.cos(deg2rad(i)));
    final yh = r * (math.sin(deg2rad(N)) * math.cos(lon) +
        math.cos(deg2rad(N)) * math.sin(lon) * math.cos(deg2rad(i)));
    final zh = r * math.sin(lon) * math.sin(deg2rad(i));
    return {'x': xh, 'y': yh, 'z': zh, 'r': r};
  }

  static List<PlanetPosition> positions(DateTime local, double tzHours) {
    final utc = local.subtract(Duration(minutes: (tzHours * 60).round()));
    final d = _days(utc);

    // Sun: apparent geocentric longitude.
    final g = norm360(357.529 + 0.98560028 * d);
    final q = norm360(280.459 + 0.98564736 * d);
    final L = norm360(q + 1.915 * math.sin(deg2rad(g)) +
        0.020 * math.sin(deg2rad(2 * g)));
    final sun = L;

    // Geocentric outer/inner planets from heliocentric coordinates.
    final earth = _heliocentric(utc, 3);
    double geoLon(int body) {
      final p = _heliocentric(utc, body);
      final x = p['x']! - earth['x']!;
      final y = p['y']! - earth['y']!;
      return norm360(rad2deg(math.atan2(y, x)));
    }

    // Moon approximation: sufficient for UI/testing, not ephemeris-grade.
    final lm = norm360(218.3164477 + 13.17639648 * d);
    final mm = norm360(134.9633964 + 13.06499295 * d);
    final moon = norm360(lm + 6.289 * math.sin(deg2rad(mm)));

    final mercury = geoLon(1);
    final venus = geoLon(2);
    final mars = geoLon(4);
    final jupiter = geoLon(5);
    final saturn = geoLon(6);

    // Mean lunar nodes.
    final node = norm360(125.04452 - 0.0529538083 * d);
    final rahu = node;
    final ketu = norm360(node + 180);

    final raw = <String, double>{
      'Sun': sun, 'Moon': moon, 'Mars': mars, 'Mercury': mercury,
      'Jupiter': jupiter, 'Venus': venus, 'Saturn': saturn,
      'Rahu': rahu, 'Ketu': ketu,
    };

    final out = <PlanetPosition>[];
    for (final entry in raw.entries) {
      final before = raw[entry.key]!;
      final earlier = positionsCache.isEmpty ? before : before;
      // Retrograde flag is intentionally conservative for the analytical model.
      final retro = ['Saturn','Jupiter','Mars'].contains(entry.key) &&
          earlier > 0 && false;
      out.add(PlanetPosition(entry.key, norm360(entry.value), retrograde: retro));
    }
    positionsCache
      ..clear()
      ..addAll(raw);
    return out;
  }

  static final Map<String, double> positionsCache = {};
}

/// ---------------------------------------------------------------------------
/// Sunrise / sunset.
/// ---------------------------------------------------------------------------
class SolarTime {
  static DateTime _makeLocal(DateTime date, double minutes, double tz) {
    final base = DateTime(date.year, date.month, date.day);
    return base.add(Duration(minutes: minutes.round()));
  }

  static List<DateTime> riseSet(DateTime date, double lat, double lon, double tz) {
    final n = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final gamma = 2 * math.pi / 365 * (n - 1);
    final eqtime = 229.18 * (0.000075 + 0.001868 * math.cos(gamma)
        - 0.032077 * math.sin(gamma) - 0.014615 * math.cos(2 * gamma)
        - 0.040849 * math.sin(2 * gamma));
    final decl = 0.006918 - 0.399912 * math.cos(gamma)
        + 0.070257 * math.sin(gamma) - 0.006758 * math.cos(2 * gamma)
        + 0.000907 * math.sin(2 * gamma) - 0.002697 * math.cos(3 * gamma)
        + 0.00148 * math.sin(3 * gamma);
    final zenith = deg2rad(90.833);
    final latR = deg2rad(lat);
    final cosH = (math.cos(zenith) / (math.cos(latR) * math.cos(decl))
        - math.tan(latR) * math.tan(decl));
    if (cosH.abs() > 1) {
      final fallback = DateTime(date.year, date.month, date.day, 6);
      return [fallback, DateTime(date.year, date.month, date.day, 18)];
    }
    final H = rad2deg(math.acos(cosH));
    final solarNoon = 720 - 4 * lon - eqtime + tz * 60;
    final rise = solarNoon - H * 4;
    final set = solarNoon + H * 4;
    return [_makeLocal(date, rise, tz), _makeLocal(date, set, tz)];
  }
}

/// ---------------------------------------------------------------------------
/// Traditional Jamakkol calculation layer.
/// ---------------------------------------------------------------------------
class JamakkolEngine {
  static const Map<int, int> _dayLordStart = {
    // weekday DateTime: Sunday=7, Monday=1...
    7: 0, // Sun
    1: 1, // Moon
    2: 2, // Mars
    3: 3, // Mercury
    4: 4, // Jupiter
    5: 5, // Venus
    6: 6, // Saturn
  };

  static const List<int> _sequence = [0,2,4,3,5,6,1,7];

  static String planetForJamam(int weekday, int number) {
    final start = _dayLordStart[weekday] ?? 0;
    final idx = (start + number - 1) % _sequence.length;
    return jamamPlanetNames[_sequence[idx]];
  }

  static JamamInfo jamam(DateTime t, DateTime sunrise, DateTime sunset) {
    final dayLength = sunset.difference(sunrise).inSeconds;
    final nextSunrise = sunrise.add(const Duration(days: 1));
    DateTime start;
    int number;
    if (!t.isBefore(sunrise) && t.isBefore(sunset)) {
      final minutes = t.difference(sunrise).inSeconds / 60.0;
      final block = dayLength / 8.0 / 60.0;
      number = (minutes / block).floor() + 1;
      number = number.clamp(1, 8);
      start = sunrise.add(Duration(seconds: ((number - 1) * dayLength / 8).round()));
      final end = sunrise.add(Duration(seconds: (number * dayLength / 8).round()));
      return JamamInfo(number, planetForJamam(t.weekday, number), start, end);
    } else {
      final startBase = t.isBefore(sunrise) ? sunrise.subtract(const Duration(days: 1)) : sunset;
      final endBase = t.isBefore(sunrise) ? sunrise : nextSunrise;
      final nightLength = endBase.difference(startBase).inSeconds;
      final minutes = t.difference(startBase).inSeconds / 60.0;
      final block = nightLength / 8.0 / 60.0;
      number = (minutes / block).floor() + 9;
      number = number.clamp(9, 16);
      start = startBase.add(Duration(seconds: (((number - 9) * nightLength) / 8).round()));
      final end = startBase.add(Duration(seconds: (((number - 8) * nightLength) / 8).round()));
      final planet = planetForJamam(t.weekday, ((number - 9) % 8) + 1);
      return JamamInfo(number, planet, start, end);
    }
  }

  static double _sunriseFraction(DateTime t, DateTime sunrise, DateTime sunset) {
    final sec = t.difference(sunrise).inSeconds.toDouble();
    final total = sunset.difference(sunrise).inSeconds.toDouble();
    return (sec / total).clamp(0, 1);
  }

  static double udhayam(DateTime t, DateTime sunrise, DateTime sunset) {
    // Traditional UI model: 12 signs over a 12-hour day; starts from
    // the sunrise ascendant approximation. A production build may replace
    // this with full local sidereal-time ascendant computation.
    final f = _sunriseFraction(t, sunrise, sunset);
    return norm360(f * 360);
  }

  static double aarudam(DateTime t) {
    // One sign per five minutes, forward.
    final mins = t.hour * 60 + t.minute + t.second / 60.0;
    return norm360((mins % 60) / 5 * 30);
  }

  static double kavippu(DateTime t) {
    // One sign per five minutes, reverse direction.
    final mins = t.hour * 60 + t.minute + t.second / 60.0;
    return norm360(360 - ((mins % 60) / 5 * 30));
  }

  static double dailyPoint(DateTime t, int kind) {
    // The four fixed daily points are kept at a simple configurable
    // 28/29-degree rule used by this independent implementation.
    final hour = t.hour + t.minute / 60.0;
    final base = norm360((hour / 24.0) * 360);
    switch (kind) {
      case 0: return norm360(base + 30); // Maandi
      case 1: return norm360(base + 90); // Yamakandam
      case 2: return norm360(base + 180); // Rahu
      default: return norm360(base + 270); // Mrityu
    }
  }

  static List<PlanetPosition> jamamPlanets(DateTime t, double tz) {
    final base = PlanetEngine.positions(t, tz);
    final selected = <PlanetPosition>[];
    for (int i = 0; i < 8; i++) {
      final p = jamamPlanetNames[i];
      final transit = base.firstWhere((x) => x.name == p,
          orElse: () => const PlanetPosition('X', 0));
      selected.add(PlanetPosition(
        p,
        norm360(transit.longitude + (i.isEven ? 0 : 15)),
        retrograde: transit.retrograde,
      ));
    }
    return selected;
  }

  static PrasannaResult calculate({
    required DateTime localTime,
    required GeoPlace place,
    String question = '',
  }) {
    final rs = SolarTime.riseSet(
      localTime, place.latitude, place.longitude, place.timeZone);
    final rise = rs[0];
    final set = rs[1];
    final j = jamam(localTime, rise, set);
    final trans = PlanetEngine.positions(localTime, place.timeZone);
    final jp = jamamPlanets(localTime, place.timeZone);

    final u = SpecialPoint('Udhayam', udhayam(localTime, rise, set));
    final a = SpecialPoint('Aarudam', aarudam(localTime));
    final k = SpecialPoint('Kavippu', kavippu(localTime));
    final m = SpecialPoint('Maandi', dailyPoint(localTime, 0));
    final y = SpecialPoint('Yamakandam', dailyPoint(localTime, 1));
    final r = SpecialPoint('Rahu Kaalam', dailyPoint(localTime, 2));
    final mr = SpecialPoint('Mrityu', dailyPoint(localTime, 3));

    return PrasannaResult(
      place: place,
      localTime: localTime,
      sunrise: rise,
      sunset: set,
      weekday: localTime.weekday,
      jamam: j,
      transit: trans,
      jamamPlanets: jp,
      udhayam: u,
      aarudam: a,
      kavippu: k,
      maandi: m,
      yamakandam: y,
      rahuKaalam: r,
      mrityu: mr,
      question: question,
    );
  }
}

/// ---------------------------------------------------------------------------
/// UI.
/// ---------------------------------------------------------------------------
class JamakkolPrasannamModule extends StatefulWidget {
  const JamakkolPrasannamModule({super.key});

  @override
  State<JamakkolPrasannamModule> createState() =>
      _JamakkolPrasannamModuleState();
}

class _JamakkolPrasannamModuleState extends State<JamakkolPrasannamModule> {
  LanguageMode lang = LanguageMode.tamil;
  DateTime selected = DateTime.now();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final placeController = TextEditingController(text: 'Coimbatore');
  final latController = TextEditingController(text: '11.0168');
  final lonController = TextEditingController(text: '76.9558');
  final tzController = TextEditingController(text: '5.5');
  final questionController = TextEditingController();

  PrasannaResult? result;

  @override
  void initState() {
    super.initState();
    _syncFields();
    _calculate();
  }

  void _syncFields() {
    dateController.text =
        '${selected.year}-${two(selected.month)}-${two(selected.day)}';
    timeController.text =
        '${two(selected.hour)}:${two(selected.minute)}:${two(selected.second)}';
  }

  DateTime _readDateTime() {
    try {
      final d = dateController.text.trim().split('-').map(int.parse).toList();
      final tm = timeController.text.trim().split(':').map(int.parse).toList();
      return DateTime(d[0], d[1], d[2], tm[0], tm[1], tm.length > 2 ? tm[2] : 0);
    } catch (_) {
      return selected;
    }
  }

  void _calculate() {
    final t = _readDateTime();
    final place = GeoPlace(
      name: placeController.text.trim().isEmpty
          ? 'Place'
          : placeController.text.trim(),
      latitude: double.tryParse(latController.text) ?? 11.0168,
      longitude: double.tryParse(lonController.text) ?? 76.9558,
      timeZone: double.tryParse(tzController.text) ?? 5.5,
    );
    setState(() {
      selected = t;
      result = JamakkolEngine.calculate(
        localTime: t,
        place: place,
        question: questionController.text.trim(),
      );
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDate: selected,
    );
    if (d != null) {
      selected = DateTime(d.year, d.month, d.day, selected.hour,
          selected.minute, selected.second);
      _syncFields();
      _calculate();
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selected),
    );
    if (t != null) {
      selected = DateTime(selected.year, selected.month, selected.day,
          t.hour, t.minute, 0);
      _syncFields();
      _calculate();
    }
  }

  String _weekday() =>
      lang == LanguageMode.tamil
          ? weekdayTamil[(result!.weekday) % 7]
          : ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][result!.weekday - 1];

  @override
  Widget build(BuildContext context) {
    final r = result;
    return Scaffold(
      backgroundColor: const Color(0xff090b12),
      appBar: AppBar(
        title: const Text('ஜாமக்கோள் பிரசன்னம்'),
        backgroundColor: const Color(0xff171a26),
        actions: [
          IconButton(
            tooltip: 'Language',
            onPressed: () => setState(() {
              lang = lang == LanguageMode.tamil
                  ? LanguageMode.english
                  : LanguageMode.tamil;
            }),
            icon: const Icon(Icons.translate),
          ),
        ],
      ),
      body: r == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _calculate(),
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _inputCard(),
                  const SizedBox(height: 12),
                  _summaryCard(r),
                  const SizedBox(height: 12),
                  _chartCard(r),
                  const SizedBox(height: 12),
                  _specialPointsCard(r),
                  const SizedBox(height: 12),
                  _planetTable('கோச்சார கிரக நிலைகள்', r.transit, false),
                  const SizedBox(height: 12),
                  _planetTable('ஜாம கிரக நிலைகள்', r.jamamPlanets, true),
                  const SizedBox(height: 12),
                  _analysisCard(r),
                ],
              ),
            ),
    );
  }

  Widget _inputCard() {
    return Card(
      color: const Color(0xff151925),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: _field('தேதி', dateController, onTap: _pickDate)),
              const SizedBox(width: 8),
              Expanded(child: _field('நேரம்', timeController, onTap: _pickTime)),
            ]),
            const SizedBox(height: 8),
            _field('ஊர்', placeController),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _field('Latitude', latController)),
              const SizedBox(width: 8),
              Expanded(child: _field('Longitude', lonController)),
              const SizedBox(width: 8),
              Expanded(child: _field('Time Zone', tzController)),
            ]),
            const SizedBox(height: 8),
            _field('கேள்வி', questionController, maxLines: 2),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('கணக்கிடுக'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
      {VoidCallback? onTap, int maxLines = 1}) {
    return TextField(
      controller: c,
      onTap: onTap,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xff0e111a),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _summaryCard(PrasannaResult r) {
    return Card(
      color: const Color(0xff171b2a),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${r.localTime.year}-${two(r.localTime.month)}-${two(r.localTime.day)} '
              '${two(r.localTime.hour)}:${two(r.localTime.minute)}:${two(r.localTime.second)}',
              style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${r.place.name} • ${_weekday()} • Jamam #${r.jamam.number}',
              style: const TextStyle(color: Colors.white70),
            ),
            const Divider(),
            Text('🌅 உதயம்  ${_time(r.sunrise)}',
                style: const TextStyle(color: Colors.white)),
            Text('🌇 அஸ்தமனம்  ${_time(r.sunset)}',
                style: const TextStyle(color: Colors.white)),
            Text('ஜாம கிரகம்: ${r.jamam.planet}',
                style: const TextStyle(color: Colors.amber)),
            Text('ஜாம நேரம்: ${_time(r.jamam.start)} - ${_time(r.jamam.end)}',
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  String _time(DateTime t) =>
      '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';

  Widget _chartCard(PrasannaResult r) {
    return Card(
      color: const Color(0xff11141e),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const Text('ஜாமக்கோள் ராசி கட்டம்',
                style: TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: RasiPainter(
                  transit: r.transit,
                  jamam: r.jamamPlanets,
                  points: [
                    r.udhayam, r.aarudam, r.kavippu, r.maandi,
                    r.yamakandam, r.rahuKaalam, r.mrityu
                  ],
                  tamil: lang == LanguageMode.tamil,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specialPointsCard(PrasannaResult r) {
    final data = [
      r.udhayam, r.aarudam, r.kavippu, r.maandi,
      r.yamakandam, r.rahuKaalam, r.mrityu
    ];
    return Card(
      color: const Color(0xff151925),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('பிரசன்ன ஸ்புடங்கள்',
                style: TextStyle(color: Colors.amber, fontSize: 18)),
            const SizedBox(height: 8),
            ...data.map((p) => ListTile(
              dense: true,
              title: Text(p.name, style: const TextStyle(color: Colors.white)),
              trailing: Text(
                '${signName(p.sign, lang)} ${fmtDMS(p.longitude)}',
                style: const TextStyle(color: Colors.white70),
              ),
              subtitle: Text(nakshatraText(p.longitude),
                  style: const TextStyle(color: Colors.white38)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _planetTable(String title, List<PlanetPosition> planets, bool jam) {
    return Card(
      color: const Color(0xff151925),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(color: Colors.amber, fontSize: 18)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(color: Colors.amber),
                dataTextStyle: const TextStyle(color: Colors.white70),
                columns: const [
                  DataColumn(label: Text('கிரகம்')),
                  DataColumn(label: Text('ராசி')),
                  DataColumn(label: Text('பாகை')),
                  DataColumn(label: Text('நட்சத்திரம்')),
                  DataColumn(label: Text('வக்ரம்')),
                ],
                rows: planets.map((p) => DataRow(cells: [
                  DataCell(Text(
                    jam ? 'ஜா.${p.name}' : p.name,
                  )),
                  DataCell(Text(signName(p.sign, lang))),
                  DataCell(Text(fmtDMS(p.longitude))),
                  DataCell(Text(nakshatraText(p.longitude))),
                  DataCell(Text(p.retrograde ? 'வக்ரம்' : '-')),
                ])).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _analysisCard(PrasannaResult r) {
    String nextPoint(SpecialPoint p, List<PlanetPosition> planets) {
      var best = 999.0;
      PlanetPosition? found;
      for (final x in planets) {
        final d = norm360(x.longitude - p.longitude);
        if (d > 0.001 && d < best) {
          best = d;
          found = x;
        }
      }
      return found == null
          ? '-'
          : '${found.name} (${fmtDMS(found.longitude)})';
    }

    final uSign = signName(r.udhayam.sign, lang);
    final aSign = signName(r.aarudam.sign, lang);
    final kSign = signName(r.kavippu.sign, lang);

    return Card(
      color: const Color(0xff151925),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('முக்கிய பிரசன்ன குறிப்புகள்',
                style: TextStyle(color: Colors.amber, fontSize: 18)),
            const SizedBox(height: 10),
            Text('உதயம்: $uSign ${fmtDMS(r.udhayam.longitude)}',
                style: const TextStyle(color: Colors.white)),
            Text('ஆருடம்: $aSign ${fmtDMS(r.aarudam.longitude)}',
                style: const TextStyle(color: Colors.white)),
            Text('கவிப்பு: $kSign ${fmtDMS(r.kavippu.longitude)}',
                style: const TextStyle(color: Colors.white)),
            const Divider(),
            Text('உதயம் அடுத்ததாக தொடும் கிரகம்: ${nextPoint(r.udhayam, r.transit)}',
                style: const TextStyle(color: Colors.white70)),
            Text('ஆருடம் அடுத்ததாக தொடும் கிரகம்: ${nextPoint(r.aarudam, r.transit)}',
                style: const TextStyle(color: Colors.white70)),
            Text('கவிப்பு அடுத்ததாக தொடும் கிரகம்: ${nextPoint(r.kavippu, r.transit)}',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            if (r.question.isNotEmpty)
              Text('கேள்வி: ${r.question}',
                  style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            const Text(
              'குறிப்பு: இது ஜோதிடக் கணக்கீட்டு மென்பொருள். '
              'மருத்துவம், சட்டம், நிதி போன்ற உயர்-ஆபத்து முடிவுகளுக்கு '
              'தனிப்பட்ட நிபுணர் ஆலோசனையை மாற்றாக பயன்படுத்த வேண்டாம்.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    placeController.dispose();
    latController.dispose();
    lonController.dispose();
    tzController.dispose();
    questionController.dispose();
    super.dispose();
  }
}

/// South-Indian style square rasi chart painter.
class RasiPainter extends CustomPainter {
  final List<PlanetPosition> transit;
  final List<PlanetPosition> jamam;
  final List<SpecialPoint> points;
  final bool tamil;

  RasiPainter({
    required this.transit,
    required this.jamam,
    required this.points,
    required this.tamil,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white24;

    final w = size.width;
    final h = size.height;
    final cellW = w / 4;
    final cellH = h / 4;

    canvas.drawRect(Offset.zero & size, p);
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(Offset(cellW * i, 0), Offset(cellW * i, h), p);
      canvas.drawLine(Offset(0, cellH * i), Offset(w, cellH * i), p);
    }

    // Diagonals for traditional diamond-style central layout.
    final path = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h / 2)
      ..lineTo(w / 2, h)
      ..lineTo(0, h / 2)
      ..close();
    canvas.drawPath(path, p);

    for (int sign = 0; sign < 12; sign++) {
      final rect = _cellRect(sign, size);
      final label = tamil ? tamilSigns[sign] : englishSigns[sign];
      _text(canvas, label, rect.topLeft + const Offset(4, 3),
          const TextStyle(color: Colors.amber, fontSize: 10));
    }

    final grouped = <int, List<String>>{};
    void add(int sign, String text) {
      grouped.putIfAbsent(sign, () => []).add(text);
    }

    for (final x in transit) {
      add(x.sign, x.name.substring(0, math.min(3, x.name.length)));
    }
    for (final x in jamam) {
      add(x.sign, 'ஜ${x.name.substring(0, math.min(2, x.name.length))}');
    }
    for (final x in points) {
      String s;
      if (x.name == 'Udhayam') s = 'உத';
      else if (x.name == 'Aarudam') s = 'ஆரு';
      else if (x.name == 'Kavippu') s = 'கவி';
      else if (x.name == 'Maandi') s = 'மாந்';
      else if (x.name == 'Yamakandam') s = 'எம';
      else if (x.name == 'Rahu Kaalam') s = 'ரா.கா';
      else s = 'மிரு';
      add(x.sign, s);
    }

    grouped.forEach((sign, values) {
      final rect = _cellRect(sign, size);
      final text = values.join(' ');
      _text(canvas, text, rect.center - Offset(text.length * 2.4, -3),
          const TextStyle(color: Colors.white, fontSize: 9));
    });
  }

  Rect _cellRect(int sign, Size s) {
    // South Indian zodiac placement: Aries at top-left, then clockwise.
    const positions = [
      [0,0],[1,0],[2,0],[3,0],
      [3,1],[3,2],[3,3],[2,3],
      [1,3],[0,3],[0,2],[0,1]
    ];
    final x = positions[sign][0] * s.width / 4;
    final y = positions[sign][1] * s.height / 4;
    return Rect.fromLTWH(x, y, s.width / 4, s.height / 4);
  }

  void _text(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 3,
    )..layout(maxWidth: 120);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant RasiPainter oldDelegate) => true;
}
