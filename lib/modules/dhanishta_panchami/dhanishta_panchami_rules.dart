// ===============================================================
// DHANISHTA PANCHAMI / TITHI ADAIPPU - TRADITIONAL RULES
// ===============================================================

import 'dhanishta_panchami_models.dart';

class DhanishtaPanchamiRules {
  /// Reference Configurable Traditional Adaippu Rule Table:
  /// Avittam (23)      -> 6 months
  /// Sathayam (24)     -> 6 months
  /// Poorattathi (25)  -> 6 months
  /// Uthirattathi (26) -> 6 months
  /// Revathi (27)      -> 6 months
  /// Rohini (4)        -> 4 months
  /// Karthigai (3)     -> 3 months
  /// Uthiram (12)      -> 3 months
  /// Mrigashiram (5)   -> 2 months
  /// Punarpoosam (7)   -> 2 months
  /// Chithirai (14)    -> 2 months
  /// Visakam (16)      -> 2 months
  /// Uthiradam (21)    -> 2 months
  /// All other Nakshatras -> 0 (அடைப்பு இல்லை)
  static const Map<int, AdaippuData> adaippuRules = {
    23: AdaippuData(6, 'ஆறு மாத அடைப்பு'),
    24: AdaippuData(6, 'ஆறு மாத அடைப்பு'),
    25: AdaippuData(6, 'ஆறு மாத அடைப்பு'),
    26: AdaippuData(6, 'ஆறு மாத அடைப்பு'),
    27: AdaippuData(6, 'ஆறு மாத அடைப்பு'),
    4: AdaippuData(4, 'நான்கு மாத அடைப்பு'),
    3: AdaippuData(3, 'மூன்று மாத அடைப்பு'),
    12: AdaippuData(3, 'மூன்று மாத அடைப்பு'),
    5: AdaippuData(2, 'இரண்டு மாத அடைப்பு'),
    7: AdaippuData(2, 'இரண்டு மாத அடைப்பு'),
    14: AdaippuData(2, 'இரண்டு மாத அடைப்பு'),
    16: AdaippuData(2, 'இரண்டு மாத அடைப்பு'),
    21: AdaippuData(2, 'இரண்டு மாத அடைப்பு'),
  };

  /// Check whether nakshatra is in the Panchaka sequence (Avittam 23 to Revati 27)
  static bool isPanchakaNakshatra(int nakshatraNumber) {
    return nakshatraNumber >= 23 && nakshatraNumber <= 27;
  }

  /// Get Adaippu information for a Nakshatra (1..27)
  static AdaippuData getAdaippuData(int nakshatraNumber) {
    return adaippuRules[nakshatraNumber] ?? const AdaippuData(0, 'அடைப்பு இல்லை');
  }

  /// Accurate calendar-month arithmetic to compute closure end date
  /// Handles month-end boundaries safely (e.g. 31 Jan + 1 mo = 28/29 Feb, 31 Aug + 1 mo = 30 Sep).
  static DateTime? calculateClosureEndDate(DateTime deathDateTime, int months) {
    if (months <= 0) return null;
    final totalMonths = (deathDateTime.year * 12 + deathDateTime.month - 1) + months;
    final newYear = totalMonths ~/ 12;
    final newMonth = (totalMonths % 12) + 1;
    // DateTime(newYear, newMonth + 1, 0).day returns the exact last day of newMonth
    final maxDaysInMonth = DateTime(newYear, newMonth + 1, 0).day;
    final newDay = deathDateTime.day > maxDaysInMonth ? maxDaysInMonth : deathDateTime.day;
    return DateTime(
      newYear,
      newMonth,
      newDay,
      deathDateTime.hour,
      deathDateTime.minute,
    );
  }

  /// Traditional disclaimer note
  static const String traditionalDisclaimer =
      'இவை பாரம்பரிய/சம்பிரதாய வழிமுறைகள். குடும்ப குலாசாரம் மற்றும் தகுந்த ஆசார்யர்/புரோகிதரின் வழிகாட்டுதலை முன்னுரிமையாகக் கொள்ளவும்.';

  /// Traditional remedies list
  static List<String> getRemedies({
    required int nakshatraNumber,
    required bool isDhanishtaPanchami,
    required bool isPanchaka,
    required int closureMonths,
  }) {
    if (isDhanishtaPanchami || isPanchaka) {
      return [
        'வீடு சுத்தி மற்றும் புண்ணியாகவாசனம்: சாஸ்திர முறைப்படி வீட்டை சுத்தி செய்து புண்ணியாகவாசனம் செய்தல்.',
        'ருத்ர சாந்தி & நவகிரக சாந்தி: தகுந்த வேத விற்பன்னர்களின் வழிகாட்டுதலுடன் ருத்ர ஏகாதசி ஜபம் மற்றும் நவகிரக சாந்தி ஹோமம் மேற்கொள்ளுதல்.',
        'எம தீபம் & சிவ வழிபாடு: மாலையில் தெற்கு நோக்கி எம தீபம் ஏற்றுதல் மற்றும் சிவபெருமானுக்கு வில்வ அர்ச்சனை செய்தல்.',
        'அடைப்பு முறை: சாஸ்திர மரபுப்படி ஆறு மாத காலம் விசேஷ காரியங்கள் தவிர்க்கப்பட்டு, வீடு அடைப்பு வழக்கம் இருப்பின் முறைப்படி கடைப்பிடித்தல்.',
        'தான தர்மங்கள்: எள் தானம், வஸ்திர தானம், தீப தானம் மற்றும் ஏழைகளுக்கு அன்னதானம் செய்தல்.',
        'குலதெய்வ வழிபாடு: குடும்ப குலதெய்வக் கோவிலுக்குச் சென்று சிறப்பு அர்ச்சனை மற்றும் வழிபாடு செய்தல்.',
      ];
    } else if (closureMonths > 0) {
      return [
        'தோஷ நிவர்த்தி சாந்தி: $closureMonths மாத அடைப்பு காலத்திற்குரிய சாந்தி வழிபாடுகளை ஆசார்யர் வழிகாட்டுதலுடன் செய்தல்.',
        'தினசரி தீப வழிபாடு: காலை மற்றும் மாலையில் இல்லத்தில் நெய் தீபம் ஏற்றி இஷ்ட தெய்வத்தை வழிபடுதல்.',
        'தானங்கள்: ஏழைகளுக்கு அன்னதானம் மற்றும் எளிய தானங்கள் வழங்கி பித்ருக்களின் ஆசி பெறுதல்.',
        'அடைப்பு முடிவு புண்ணியாகவாசனம்: அடைப்பு காலம் முடிவுற்றதும் புண்ணியாகவாசனம் செய்து இல்லத்தை சுத்தி செய்தல்.',
        'குலதெய்வ பிரார்த்தனை: அடைப்பு காலம் பூர்த்தியானதும் குலதெய்வத்தை தரிசித்து நேர்த்திக்கடன் செலுத்துதல்.',
      ];
    } else {
      return [
        'வழக்கமான பித்ரு காரியங்கள்: விசேஷ அடைப்பு தோஷம் ஏதுமில்லை. சாஸ்திர முறைப்படி உரிய தினங்களில் பித்ரு தர்ப்பணங்களைச் செய்யவும்.',
        'இறை வழிபாடு: குலதெய்வம் மற்றும் இஷ்ட தெய்வ வழிபாட்டினைத் தொடர்ந்து மேற்கொள்ளவும்.',
      ];
    }
  }
}
