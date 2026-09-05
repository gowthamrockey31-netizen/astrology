import 'jamakkol_models.dart';

/// Rule Engine for ஜாமகோள் ஆருடம் Model 2
class JamakkolRuleEngine {
  /// Predict Prasannam outcomes based on classical Jamakkol rules
  static List<String> predict({
    required MarkPosition udhayam,
    required MarkPosition arudham,
    required MarkPosition kavippu,
    required List<JamakkolPlanetInfo> outerPlanets,
    required List<JamakkolPlanetInfo> transitPlanets,
    String jamamLord = 'சூரியன்',
    bool isDayJamam = true,
  }) {
    final List<String> predictions = [];

    // 1. உதயம் (Udhayam / Questioner's State)
    final udhayamRasi = udhayam.rasiName;
    predictions.add(
      'உதயம் ($udhayamRasi ராசியில்): கேள்வி கேட்பவரின் தற்போதைய மனநிலை மற்றும் முயற்சியின் தொடக்கத்தைக் குறிக்கிறது. '
      'உதய ராசியானது காரியத் தொடக்கத்திற்கு ஸ்திரமான சக்தியைத் தருகிறது.',
    );

    // 2. ஆருடம் (Arudham / Matter of Question)
    final arudhamHouseFromUdhayam = arudham.house;
    final arudhamRasi = arudham.rasiName;

    if (arudhamHouseFromUdhayam == 1) {
      predictions.add(
        'ஆருடம் உதயத்திலேயே அமைந்துள்ளது (1-ஆம் பாவம் - $arudhamRasi): கேட்கப்பட்ட காரியம் உடனடியாகவும் சாதகமாகவும் முடிவடையும். '
        'கேள்வி கேட்பவரின் நேரடி கட்டுப்பாட்டில் சூழ்நிலைகள் உள்ளன.',
      );
    } else if (arudhamHouseFromUdhayam == 5 || arudhamHouseFromUdhayam == 9) {
      predictions.add(
        'ஆருடம் திரிகோண ஸ்தானத்தில் அமைந்துள்ளது ($arudhamHouseFromUdhayam-ஆம் பாவம் - $arudhamRasi): '
        'தெய்வ அனுகூலமும் பூர்வ புண்ணிய பலமும் நிறைந்துள்ளன. காரிய வெற்றி மிகச் சுலபமாக கைகூடும்.',
      );
    } else if (arudhamHouseFromUdhayam == 4 ||
        arudhamHouseFromUdhayam == 7 ||
        arudhamHouseFromUdhayam == 10) {
      predictions.add(
        'ஆருடம் கேந்திர ஸ்தானத்தில் அமைந்துள்ளது ($arudhamHouseFromUdhayam-ஆம் பாவம் - $arudhamRasi): '
        'முயற்சிக்குரிய பலன் உறுதியாகக் கிடைக்கும். பெரியோர்கள் மற்றும் அதிகாரிகளின் ஆதரவு உண்டு.',
      );
    } else if (arudhamHouseFromUdhayam == 2 || arudhamHouseFromUdhayam == 11) {
      predictions.add(
        'ஆருடம் தன / லாப ஸ்தானத்தில் அமைந்துள்ளது ($arudhamHouseFromUdhayam-ஆம் பாவம் - $arudhamRasi): '
        'பொருளாதார மேன்மை, நன்மைகள் மற்றும் கூடுதல் லாபங்களை எதிர்பார்க்கலாம்.',
      );
    } else if (arudhamHouseFromUdhayam == 3) {
      predictions.add(
        'ஆருடம் தைரிய ஸ்தானத்தில் ($arudhamHouseFromUdhayam-ஆம் பாவம்): தீவிர முயற்சி மற்றும் விடாமுயற்சியின் மூலம் வெற்றி சாத்தியமாகும்.',
      );
    } else {
      // 6, 8, 12 Dusthanas
      predictions.add(
        'ஆருடம் மறைவு ஸ்தானத்தில் அமைந்துள்ளது ($arudhamHouseFromUdhayam-ஆம் பாவம் - $arudhamRasi): '
        'காரியத்தில் சில தடைகள், தாமதங்கள் அல்லது எதிர்பாராத செலவுகள் ஏற்படக்கூடும். எச்சரிக்கையும் பொறுமையும் தேவை.',
      );
    }

    // 3. கவிப்பு (Kavippu / Obstacle & Danger Point)
    final kavippuHouseFromUdhayam = kavippu.house;
    final kavippuRasi = kavippu.rasiName;

    // Check if Kavippu is conjunct Udhayam or Arudham
    if (kavippu.rasiIndex == udhayam.rasiIndex) {
      predictions.add(
        'கவிப்பு உதயத்தில் இணைந்துள்ளது: கேள்வி கேட்பவருக்கு ஆரம்பக் குழப்பங்கள் அல்லது உடல்/மன ரீதியான சோர்வு ஏற்பட வாய்ப்புள்ளது. இறைவழிபாடு பரிகாரம் நன்மை தரும்.',
      );
    } else if (kavippu.rasiIndex == arudham.rasiIndex) {
      predictions.add(
        'கவிப்பு ஆருடத்தில் இணைந்துள்ளது: கேட்கப்பட்ட காரியத்தில் முக்கிய தடை அல்லது மறைமுக எதிர்ப்புகள் உள்ளன. அவசர முடிவுகளைத் தவிர்ப்பது உத்தமம்.',
      );
    } else {
      predictions.add(
        'கவிப்பு $kavippuRasi ராசியில் ($kavippuHouseFromUdhayam-ஆம் பாவம்): இந்த பாவத்தின் காரகத்துவங்களில் விழிப்புணர்வுடன் செயல்பட வேண்டும்.',
      );
    }

    // 4. வெளிவட்ட கிரகங்களின் தாக்கம் (Outer Jamam Planets)
    final outerInUdhayam = outerPlanets.where((p) => p.rasiIndex == udhayam.rasiIndex).toList();
    final outerInArudham = outerPlanets.where((p) => p.rasiIndex == arudham.rasiIndex).toList();

    if (outerInUdhayam.isNotEmpty) {
      final names = outerInUdhayam.map((p) => p.tamilName).join(', ');
      predictions.add(
        'வெளிவட்ட கிரகம் ($names) உதயத்தில் சஞ்சரிக்கிறது: உதயாதிபதியின் பலத்துடன் இந்த கிரகத்தின் காரகத்துவங்கள் நேரடியாகச் செயல்படும்.',
      );
    }

    if (outerInArudham.isNotEmpty) {
      final names = outerInArudham.map((p) => p.tamilName).join(', ');
      predictions.add(
        'வெளிவட்ட கிரகம் ($names) ஆருடத்தில் சஞ்சரிக்கிறது: கேட்கப்பட்ட காரியத்திற்கு இந்த வெளிவட்ட கிரகம் விரைவுபடுத்தும் அல்லது மாற்றத்தை ஏற்படுத்தும்.',
      );
    }

    // 5. கோச்சார கிரகங்களின் தொடர்பு (Transit Planets)
    final transitInArudham = transitPlanets.where((p) => p.rasiIndex == arudham.rasiIndex).toList();
    if (transitInArudham.isNotEmpty) {
      final pNames = transitInArudham.map((p) => p.tamilName).join(', ');
      predictions.add(
        'கோச்சார கிரகம் ($pNames) ஆருட ராசியில் அமர்ந்துள்ளது: தற்போதைய கிரக சஞ்சாரம் காரிய வெற்றிக்கு சாதகமான வழியைத் திறந்து விடுகிறது.',
      );
    }

    // 6. ராகு/கேது அச்சு (Rahu/Ketu Axis)
    final rahuTransit = transitPlanets.where((p) => p.position.planet.name.toLowerCase() == 'rahu').firstOrNull;
    final ketuTransit = transitPlanets.where((p) => p.position.planet.name.toLowerCase() == 'ketu').firstOrNull;

    if (rahuTransit != null && (rahuTransit.rasiIndex == udhayam.rasiIndex || rahuTransit.rasiIndex == arudham.rasiIndex)) {
      predictions.add(
        'கோச்சார ராகுவின் தாக்கம் உதயம்/ஆருடத்தில் உள்ளது: எதிர்பாராத திடீர் திருப்பங்கள் மற்றும் புதிய வாய்ப்புகள் உருவாகும்.',
      );
    }
    if (ketuTransit != null && (ketuTransit.rasiIndex == udhayam.rasiIndex || ketuTransit.rasiIndex == arudham.rasiIndex)) {
      predictions.add(
        'கோச்சார கேதுவின் தாக்கம் உதயம்/ஆருடத்தில் உள்ளது: ஆன்மீக ஈடுபாடு மற்றும் தியாக உணர்வு காரிய வெற்றியைத் தரும்.',
      );
    }

    // 7. சாம அதிபதி (Jamam Lord)
    predictions.add(
      'தற்போதைய சாம அதிபதி: $jamamLord (${isDayJamam ? 'பகல்' : 'இரவு'} சாமம்). இந்த சாம நாதனின் சுப ஆதிக்கம் காரியத்தின் திசையைத் தீர்மானிக்கிறது.',
    );

    return predictions;
  }
}
