import 'package:flutter/material.dart';
import 'professional_muhurtha_models.dart';
import 'professional_muhurtha_engine.dart';

/// ===============================================================
/// FLUTTER UI
/// ===============================================================

class ProfessionalMuhurthaPage extends StatefulWidget {
  final GeoLocation location;

  const ProfessionalMuhurthaPage({
    super.key,
    this.location = const GeoLocation(
      name: 'Coimbatore',
      latitude: 11.0168,
      longitude: 76.9558,
      timeZone: 5.5,
    ),
  });

  @override
  State<ProfessionalMuhurthaPage> createState() =>
      _ProfessionalMuhurthaPageState();
}

class _ProfessionalMuhurthaPageState
    extends State<ProfessionalMuhurthaPage> {
  final engine = ProfessionalMuhurthaEngine();

  DateTime selectedDate = DateTime.now();

  MuhurthaActivity activity = MuhurthaActivity.general;

  MuhurthaMode mode = MuhurthaMode.general;

  MuhurthaResult? result;

  BirthProfile? birth;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final r = engine.calculate(
      date: selectedDate,
      location: widget.location,
      activity: activity,
      mode: mode,
      birth: birth,
    );

    setState(() {
      result = r;
    });
  }

  String _time(
    DateTime value,
  ) {
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _activityName(
    MuhurthaActivity a,
  ) {
    switch (a) {
      case MuhurthaActivity.general:
        return 'பொதுவான காரியம்';
      case MuhurthaActivity.marriage:
        return 'திருமணம்';
      case MuhurthaActivity.business:
        return 'தொழில் தொடக்கம்';
      case MuhurthaActivity.houseConstruction:
        return 'வீடு கட்டுதல்';
      case MuhurthaActivity.houseEntry:
        return 'கிரகப்பிரவேசம்';
      case MuhurthaActivity.propertyPurchase:
        return 'சொத்து வாங்குதல்';
      case MuhurthaActivity.vehiclePurchase:
        return 'வாகனம் வாங்குதல்';
      case MuhurthaActivity.education:
        return 'கல்வி';
      case MuhurthaActivity.travel:
        return 'பயணம்';
      case MuhurthaActivity.agriculture:
        return 'விவசாயம்';
      case MuhurthaActivity.naming:
        return 'பெயர் சூட்டுதல்';
      case MuhurthaActivity.medical:
        return 'மருத்துவம்';
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _calculate();
      });
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final r = result;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Professional நல்ல நேரம்',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'தேதி தேர்வு (Select Date)',
            onPressed: _pickDate,
          ),
        ],
      ),
      body: r == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _summaryCard(r),
                const SizedBox(height: 16),
                DropdownButtonFormField<MuhurthaActivity>(
                  initialValue: activity,
                  decoration: const InputDecoration(
                    labelText: 'செய்யும் காரியம்',
                    border: OutlineInputBorder(),
                  ),
                  items: MuhurthaActivity.values
                      .map(
                        (a) => DropdownMenuItem(
                          value: a,
                          child: Text(
                            _activityName(a),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;

                    activity = v;
                    _calculate();
                  },
                ),
                const SizedBox(height: 12),
                SegmentedButton<MuhurthaMode>(
                  segments: const [
                    ButtonSegment(
                      value: MuhurthaMode.general,
                      label: Text('பொதுவானது'),
                    ),
                    ButtonSegment(
                      value: MuhurthaMode.personal,
                      label: Text('தனிப்பட்டது'),
                    ),
                  ],
                  selected: {mode},
                  onSelectionChanged: (values) {
                    mode = values.first;
                    if (mode == MuhurthaMode.personal && birth == null) {
                      birth = BirthProfile(
                        birthDate: DateTime(1995, 1, 1),
                        birthNakshatra: 1,
                        birthRasi: 0,
                      );
                    }
                    _calculate();
                  },
                ),
                if (mode == MuhurthaMode.personal) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ஜாதகர் விவரம் (தாராபலம் & சந்திரபலம்)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: birth?.birthNakshatra ?? 1,
                                  decoration: const InputDecoration(
                                    labelText: 'பிறந்த நட்சத்திரம்',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                  ),
                                  items: List.generate(
                                    ProfessionalMuhurthaEngine.nakshatras.length,
                                    (i) => DropdownMenuItem(
                                      value: i + 1,
                                      child: Text(
                                        ProfessionalMuhurthaEngine.nakshatras[i],
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ),
                                  onChanged: (v) {
                                    if (v == null) return;
                                    setState(() {
                                      birth = BirthProfile(
                                        birthDate: birth?.birthDate ??
                                            DateTime(1995, 1, 1),
                                        birthNakshatra: v,
                                        birthRasi: birth?.birthRasi ?? 0,
                                      );
                                      _calculate();
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: birth?.birthRasi ?? 0,
                                  decoration: const InputDecoration(
                                    labelText: 'பிறந்த ராசி',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                  ),
                                  items: List.generate(
                                    ProfessionalMuhurthaEngine.rasis.length,
                                    (i) => DropdownMenuItem(
                                      value: i,
                                      child: Text(
                                        ProfessionalMuhurthaEngine.rasis[i],
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ),
                                  onChanged: (v) {
                                    if (v == null) return;
                                    setState(() {
                                      birth = BirthProfile(
                                        birthDate: birth?.birthDate ??
                                            DateTime(1995, 1, 1),
                                        birthNakshatra:
                                            birth?.birthNakshatra ?? 1,
                                        birthRasi: v,
                                      );
                                      _calculate();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _sunCard(r),
                const SizedBox(height: 16),
                _avoidCard(
                  'ராகுகாலம்',
                  r.rahuKalam,
                ),
                _avoidCard(
                  'எமகண்டம்',
                  r.yamagandam,
                ),
                _avoidCard(
                  'குளிகை',
                  r.gulikai,
                ),
                const SizedBox(height: 20),
                const Text(
                  '⭐ சிறந்த முகூர்த்த நேரங்கள்',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...r.bestWindows.map(
                  _bestWindowCard,
                ),
                const SizedBox(height: 20),
                const Text(
                  '⚠️ தவிர்க்க வேண்டிய நேரங்கள்',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...r.avoidWindows
                    .take(5)
                    .map(
                      (w) => _windowCard(
                        w,
                        false,
                      ),
                    ),
              ],
            ),
    );
  }

  Widget _summaryCard(
    MuhurthaResult r,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.location.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.amber),
                  const SizedBox(width: 6),
                  Text(
                    '${r.date.day}/${r.date.month}/${r.date.year}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit_calendar, size: 16, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              r.finalRecommendation,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'அதிகபட்ச Score: ${r.highestScore.toStringAsFixed(0)}/100',
            ),
          ],
        ),
      ),
    );
  }

  Widget _sunCard(
    MuhurthaResult r,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text('🌅 உதயம்'),
                const SizedBox(height: 6),
                Text(
                  _time(r.sunrise),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Text('🌇 அஸ்தமனம்'),
                const SizedBox(height: 6),
                Text(
                  _time(r.sunset),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _avoidCard(
    String title,
    MuhurthaWindow w,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.warning),
        title: Text(title),
        subtitle: Text(
          '${_time(w.start)} - ${_time(w.end)}',
        ),
      ),
    );
  }

  Widget _bestWindowCard(
    MuhurthaWindow w,
  ) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(
          Icons.check_circle,
        ),
        title: Text(
          '${_time(w.start)} - ${_time(w.end)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${w.category} • ${w.score.toStringAsFixed(0)}/100',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'இந்த நேரம் ஏன் தேர்வு செய்யப்பட்டது?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...w.reasons.map(
                  (reason) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: 4,
                    ),
                    child: Text(
                      '• $reason',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _windowCard(
    MuhurthaWindow w,
    bool good,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          good ? Icons.check_circle : Icons.cancel,
        ),
        title: Text(
          '${_time(w.start)} - ${_time(w.end)}',
        ),
        subtitle: Text(
          w.category,
        ),
      ),
    );
  }
}
