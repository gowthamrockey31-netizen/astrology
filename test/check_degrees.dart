import 'package:astrocall/services/astrology_calculator.dart';

void main() {
  print('--- Testing with Dindigul (10.3673, 77.9803) ---');
  final resDindigul = AstrologyCalculator.calculateHoroscope(
    dateOfBirth: DateTime(1987, 3, 11, 9, 50, 0),
    latitude: 10.3673,
    longitude: 77.9803,
    utcOffsetHours: 5.5,
  );
  print('Ayanamsa: ${resDindigul.ayanamsaFormatted}');
  for (final entry in resDindigul.planets.entries) {
    final p = entry.value;
    print('${p.tamilName} (${p.name}): ${p.rasiNameTa} ${p.degreeFormatted} (${p.nakshatraNameTa}-${p.pada})');
  }
}
