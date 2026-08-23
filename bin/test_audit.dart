import '../lib/services/astrology_calculator.dart';
import '../lib/services/dasha_calculator.dart';
import '../lib/services/jaathaga_kurippugal_calculator.dart';
import '../lib/services/ashtakavarga_calculator.dart';
import '../lib/services/panchapakshi_calculator.dart';
import '../lib/models/user_model.dart';

void main() {
  final dob = DateTime(1987, 3, 11, 9, 50);
  final lat = 10.2785;
  final lon = 77.9244;
  final tz = 5.5;

  final user = UserModel(
    id: '1',
    name: 'Divine Seeker1',
    mobile: '+919876543210',
    gender: 'Male',
    dob: '1987-03-11',
    timeOfBirth: '09:50 AM',
    placeOfBirth: 'Dindigul,TN',
    city: 'Dindigul',
    state: 'TN',
    country: 'India',
    zodiac: 'Cancer',
    nakshatra: 'Pushya',
    lagna: 'Libra',
    walletBalance: 500.0,
    profilePhoto: '',
    latitude: lat,
    longitude: lon,
    timezone: tz,
  );

  final astroData = AstrologyCalculator.calculateHoroscope(
    dateOfBirth: dob,
    latitude: lat,
    longitude: lon,
    utcOffsetHours: tz,
  );

  print("=== ASTROLOGY CALCULATOR AUDIT ===");
  print("Ayanamsa: ${astroData.ayanamsaFormatted}");
  print("Lagna: ${astroData.lagna.rasiNameTa} (${astroData.lagna.rasiNameEn}) ${astroData.lagna.degreeFormatted}");
  print("Moon: ${astroData.moon.rasiNameTa} (${astroData.moon.rasiNameEn}) Star: ${astroData.moon.nakshatraNameTa}-${astroData.moon.pada}");
  print("Sun: ${astroData.sun.rasiNameTa} (${astroData.sun.rasiNameEn})");

  print("\n=== PANCHANGAM & DATE AUDIT ===");
  final notes = JaathagaKurippugalCalculator.calculateNotes(user: user);
  print("English Date: ${notes.englishDate}");
  print("Tamil Date: ${notes.tamilDate}");
  print("Tithi: ${notes.paksha} ${notes.thithi}");
  print("Karana: ${notes.karanam}");
  print("Yoga: ${notes.yoga}");
  print("Birth Hora: ${notes.hora}");

  final currentHora = AstrologyCalculator.calculateHora(DateTime.now());
  print("Current Live Hora: ${currentHora['ta']} (${currentHora['en']})");

  print("\n=== ASHTAKAVARGA AUDIT ===");
  final ashtakavarga = AshtakavargaCalculator.calculateAshtakavarga(astroData.planets);
  print("Total SAV Points: ${ashtakavarga.totalSavPoints}");
  print("SAV Scores per Rasi: ${ashtakavarga.sarvashtakavarga}");

  print("\n=== PANCHAPAKSHI AUDIT ===");
  final bird = PanchapakshiCalculator.getBirthBird(
    nakshatraIndex: astroData.moon.nakshatraIndex,
    isShuklaPaksha: astroData.tithi.isShuklaPaksha,
  );
  print("Birth Bird: ${bird.nameTa} (${bird.nameEn}) ${bird.symbol}");

  final currentActivity = PanchapakshiCalculator.calculateCurrentActivity(
    nakshatraIndex: astroData.moon.nakshatraIndex,
    isShuklaPaksha: astroData.tithi.isShuklaPaksha,
  );
  print("Current Live Activity: ${currentActivity.currentActivityTa} (${currentActivity.currentActivityEn}) Power: ${currentActivity.powerPercentage}%");
}
