import 'dart:math' as math;
import 'package:flutter/material.dart';

/// ===============================================================
/// AYANA KALA MODULE
/// உத்தராயணம் / தட்சிணாயணம் கணக்கீடு
///
/// Input:
///   Birth Date
///   Birth Time
///   Latitude
///   Longitude
///
/// Output:
///   Solar Longitude
///   Rasi
///   Ayana
///   Ayana Tamil
///   Ayana Start
///   Next Ayana
/// ===============================================================

class AyanaResult {
  final DateTime birthDateTime;
  final double solarLongitude;
  final String rasi;
  final String ayana;
  final String ayanaTamil;
  final DateTime ayanaStart;
  final DateTime nextAyana;
  final String description;

  AyanaResult({
    required this.birthDateTime,
    required this.solarLongitude,
    required this.rasi,
    required this.ayana,
    required this.ayanaTamil,
    required this.ayanaStart,
    required this.nextAyana,
    required this.description,
  });
}

// ===============================================================
// MAIN CALCULATOR
// ===============================================================

class AyanaCalculator {
  static const List<String> rasis = [
    'Mesha',
    'Vrishabha',
    'Mithuna',
    'Karka',
    'Simha',
    'Kanya',
    'Tula',
    'Vrischika',
    'Dhanus',
    'Makara',
    'Kumbha',
    'Meena',
  ];

  static const List<String> rasiTamil = [
    'மேஷம்',
    'ரிஷபம்',
    'மிதுனம்',
    'கடகம்',
    'சிம்மம்',
    'கன்னி',
    'துலாம்',
    'விருச்சிகம்',
    'தனுசு',
    'மகரம்',
    'கும்பம்',
    'மீனம்',
  ];

  /// -------------------------------------------------------------
  /// Main calculation
  /// -------------------------------------------------------------

  static AyanaResult calculate({
    required DateTime birthDateTime,
    double latitude = 11.0168,
    double longitude = 76.9558,
  }) {
    final solarLongitude =
        _siderealSolarLongitude(birthDateTime);

    final rasiIndex =
        (solarLongitude / 30.0).floor() % 12;

    final rasiDegree =
        solarLongitude % 30.0;

    // -----------------------------------------------------------
    // Uttarayana:
    //
    // Nirayana Surya enters Makara.
    // 270° = Makara 0°
    //
    // Dakshinayana:
    // Nirayana Surya enters Karka.
    // 90° = Karka 0°
    // -----------------------------------------------------------

    final bool isUttarayana =
        solarLongitude >= 270.0 ||
        solarLongitude < 90.0;

    final String ayana =
        isUttarayana
            ? 'Uttarayana'
            : 'Dakshinayana';

    final String ayanaTamil =
        isUttarayana
            ? 'உத்தராயணம்'
            : 'தட்சிணாயணம்';

    final DateTime ayanaStart =
        _findAyanaStart(
      birthDateTime,
      isUttarayana,
    );

    final DateTime nextAyana =
        _findAyanaStart(
      birthDateTime.add(const Duration(days: 2)),
      !isUttarayana,
    );

    final description = isUttarayana
        ? 'சூரியன் மகர ராசி முதல் மிதுன ராசி வரை செல்லும் காலம் '
            'உத்தராயணம் எனக் கணிக்கப்படுகிறது.'
        : 'சூரியன் கடக ராசி முதல் தனுசு ராசி வரை செல்லும் காலம் '
            'தட்சிணாயணம் எனக் கணிக்கப்படுகிறது.';

    return AyanaResult(
      birthDateTime: birthDateTime,
      solarLongitude: solarLongitude,
      rasi:
          '${rasiTamil[rasiIndex]} '
          '${rasiDegree.toStringAsFixed(2)}°',
      ayana: ayana,
      ayanaTamil: ayanaTamil,
      ayanaStart: ayanaStart,
      nextAyana: nextAyana,
      description: description,
    );
  }

  // =============================================================
  // Solar longitude
  // =============================================================

  static double _solarLongitude(DateTime date) {
    final jd = _julianDay(date);

    final T =
        (jd - 2451545.0) / 36525.0;

    // Mean longitude
    double L =
        280.46646 +
        36000.76983 * T +
        0.0003032 * T * T;

    L = _normalize(L);

    // Mean anomaly
    double M =
        357.52911 +
        35999.05029 * T -
        0.0001537 * T * T;

    M = _normalize(M);

    final Mrad =
        M * math.pi / 180.0;

    // Equation of center
    final C =
        (1.914602 -
                0.004817 * T -
                0.000014 * T * T) *
            math.sin(Mrad) +
        (0.019993 -
                0.000101 * T) *
            math.sin(2 * Mrad) +
        0.000289 *
            math.sin(3 * Mrad);

    final trueLongitude =
        _normalize(L + C);

    return trueLongitude;
  }

  // =============================================================
  // Approximate Lahiri ayanamsa
  // =============================================================

  static double _lahiriAyanamsa(DateTime date) {
    final jd = _julianDay(date);

    final T =
        (jd - 2451545.0) / 36525.0;

    // Approximation around modern epoch.
    //
    // For production-grade astronomical calculation,
    // replace this with a validated ephemeris implementation.
    final ayan =
        23.8531 +
        0.013968 *
            ((date.year + date.month / 12.0) -
                2000.0);

    return ayan;
  }

  // =============================================================
  // Sidereal Sun
  // =============================================================

  static double _siderealSolarLongitude(
      DateTime date) {
    final tropical =
        _solarLongitude(date);

    final ayanamsa =
        _lahiriAyanamsa(date);

    return _normalize(
      tropical - ayanamsa,
    );
  }

  // =============================================================
  // Find Ayana beginning
  //
  // Uttarayana -> Sun enters Makara 270°
  // Dakshinayana -> Sun enters Karka 90°
  // =============================================================

  static DateTime _findAyanaStart(
    DateTime date,
    bool targetUttarayana,
  ) {
    final target =
        targetUttarayana ? 270.0 : 90.0;

    DateTime low =
        date.subtract(const Duration(days: 60));

    DateTime high =
        date.add(const Duration(days: 60));

    // Binary search
    for (int i = 0; i < 40; i++) {
      final middle =
          low.add(
        Duration(
          microseconds:
              high
                  .difference(low)
                  .inMicroseconds ~/
              2,
        ),
      );

      final longitude =
          _siderealSolarLongitude(middle);

      double difference =
          _angularDifference(
        longitude,
        target,
      );

      if (difference < 0) {
        low = middle;
      } else {
        high = middle;
      }
    }

    return low;
  }

  // =============================================================
  // Angular difference
  // =============================================================

  static double _angularDifference(
      double value,
      double target) {
    double d =
        _normalize(value - target);

    if (d > 180) {
      d -= 360;
    }

    return d;
  }

  // =============================================================
  // Julian Day
  // =============================================================

  static double _julianDay(DateTime date) {
    final utc = date.toUtc();

    final y = utc.year;
    final m = utc.month;

    final d =
        utc.day +
        (utc.hour +
                utc.minute / 60.0 +
                utc.second / 3600.0) /
            24.0;

    int Y = y;
    int M = m;

    if (M <= 2) {
      Y -= 1;
      M += 12;
    }

    final A = (Y / 100).floor();
    final B =
        2 - A + (A / 4).floor();

    return (365.25 * (Y + 4716)).floor() +
        (30.6001 * (M + 1)).floor() +
        d +
        B -
        1524.5;
  }

  // =============================================================
  // Normalize 0–360
  // =============================================================

  static double _normalize(double value) {
    value %= 360.0;

    if (value < 0) {
      value += 360.0;
    }

    return value;
  }
}

// ===============================================================
// FLUTTER UI
// ===============================================================

class AyanaKalaModule extends StatefulWidget {
  const AyanaKalaModule({
    super.key,
  });

  @override
  State<AyanaKalaModule> createState() =>
      _AyanaKalaModuleState();
}

class _AyanaKalaModuleState
    extends State<AyanaKalaModule> {
  DateTime birthDate =
      DateTime(1990, 1, 1);

  TimeOfDay birthTime =
      const TimeOfDay(
    hour: 12,
    minute: 0,
  );

  double latitude = 11.0168;
  double longitude = 76.9558;

  AyanaResult? result;

  void calculate() {
    final dateTime = DateTime(
      birthDate.year,
      birthDate.month,
      birthDate.day,
      birthTime.hour,
      birthTime.minute,
    );

    setState(() {
      result = AyanaCalculator.calculate(
        birthDateTime: dateTime,
        latitude: latitude,
        longitude: longitude,
      );
    });
  }

  Future<void> selectDate() async {
    final picked =
        await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDate: birthDate,
    );

    if (picked != null) {
      setState(() {
        birthDate = picked;
      });
    }
  }

  Future<void> selectTime() async {
    final picked =
        await showTimePicker(
      context: context,
      initialTime: birthTime,
    );

    if (picked != null) {
      setState(() {
        birthTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'அயன கால கணிப்பு',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      title:
                          const Text('பிறந்த தேதி'),
                      subtitle: Text(
                        '${birthDate.day}/'
                        '${birthDate.month}/'
                        '${birthDate.year}',
                      ),
                      trailing:
                          const Icon(
                        Icons.calendar_month,
                      ),
                      onTap: selectDate,
                    ),

                    ListTile(
                      title:
                          const Text('பிறந்த நேரம்'),
                      subtitle:
                          Text(
                        birthTime.format(
                          context,
                        ),
                      ),
                      trailing:
                          const Icon(
                        Icons.access_time,
                      ),
                      onTap: selectTime,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: calculate,
                        child: const Text(
                          'அயன காலம் கணக்கிடுக',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            if (result != null)
              _resultCard(result!),
          ],
        ),
      ),
    );
  }

  Widget _resultCard(
      AyanaResult result) {
    final isUttarayana =
        result.ayana ==
            'Uttarayana';

    return Card(
      elevation: 5,
      child: Padding(
        padding:
            const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                result.ayanaTamil,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight:
                      FontWeight.bold,
                  color: isUttarayana
                      ? Colors.orange
                      : Colors.indigo,
                ),
              ),
            ),

            const Divider(
              height: 30,
            ),

            _row(
              'சூரியன் நிலை',
              '${result.solarLongitude.toStringAsFixed(4)}°',
            ),

            _row(
              'சூரிய ராசி',
              result.rasi,
            ),

            _row(
              'அயனம் தொடக்கம்',
              _formatDateTime(
                result.ayanaStart,
              ),
            ),

            _row(
              'அடுத்த அயனம்',
              _formatDateTime(
                result.nextAyana,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            Container(
              padding:
                  const EdgeInsets.all(12),
              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
                color: Colors.grey
                    .withValues(alpha: 0.12),
              ),
              child: Text(
                result.description,
                style:
                    const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(
      DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
