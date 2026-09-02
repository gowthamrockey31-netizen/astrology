import '../models/bnn_method1_model.dart';

/// Centralized BNN Method 1 Prediction Rules Repository
/// Deterministic interpretations based on classical Bhrigu Nandi Nadi combinations.
class BnnMethod1RulesRepository {
  /// Specific classical combinations in BNN
  static const Map<String, String> _specificCombinations = {
    // Sun Combinations
    'Sun_Jupiter': 'தந்தை மற்றும் உயர்கல்வி, ஆன்மீகம், அரசு மரியாதை ஆகியவை ஒருங்கிணைந்து செயல்படும். உயர்ந்த வழிகாட்டுதலும் தலைமைத்துவ பண்பும் வாழ்க்கையில் மேன்மையைத் தரும்.',
    'Sun_Saturn': 'கடின உழைப்பும் ஒழுக்கமும் மூலம் படிபடியாக உயர்வு கிடைக்கும். தந்தை வழி பொறுப்புகளும் தொழில் வழியில் தொடர் முயற்சிகளும் விவேகத்தை உருவாக்கும்.',
    'Sun_Mars': 'அதிகாரமும் வேகமும் நிறைந்த ஆளுமை. அரசு, நிர்வாகம், பாதுகாப்பு அல்லது தொழில்நுட்பத் துறையில் துணிச்சலான வெற்றிகளை ஈட்டும் திறன் உண்டு.',
    'Sun_Mercury': 'நிபுணத்துவமிக்க நிர்வாக அறிவு, எழுத்து, வர்த்தகம் மற்றும் அரசு தொடர்புகளில் திறம்பட செயலாற்றும் யோகம்.',
    'Sun_Venus': 'கலைத்துறை, சொகுசு மற்றும் பொது நிர்வாகத்தில் ஈடுபாடு. ஆடம்பரமும் கௌரவமும் சமூகத்தில் நன்மதிப்பை பெற்றுத்தரும்.',
    'Sun_Rahu': 'அரசியல், வெளிநாட்டு தொடர்புகள் மற்றும் பெருமளவிலான மக்கள் தொடர்பு மூலம் திடீர் மாற்றங்கள் உண்டாகும்.',
    'Sun_Ketu': 'ஆன்மீக சிந்தனை, தன்னடக்கம் மற்றும் உள்ளுணர்வு ஞானம் வளரும். சுய கௌரவத்தில் சமரசமற்ற பக்குவம் ஏற்படும்.',

    // Jupiter Combinations (Jeeva Karaka)
    'Jupiter_Saturn': 'தர்ம-கர்ம யோக நாடி சேர்க்கை. நீடித்த தொழில் வளர்ச்சி, சமூகத்தில் உயர்ந்த கௌரவம், நம்பகமான உழைப்பு மற்றும் மக்களின் நன்மதிப்பு உண்டாகும்.',
    'Jupiter_Sun': 'அரசு அனுகூலம், அதிகாரமிக்க பதவிகள் மற்றும் ஆன்மீக குருமார்களின் அருளாசி தொடர்ச்சியாக கிட்டும்.',
    'Jupiter_Moon': 'கஜகேசரி யோகத் தன்மை. தாயின் ஆசி, தெளிவான மனநிலை, ஆன்மீக யாத்திரைகள் மற்றும் சமுதாயத்தில் நற்பெயர் வளரும்.',
    'Jupiter_Mars': 'தைரியமும் தர்மமும் இணைந்த செயல்பாடு. நிலம், வீடு வாங்கும் யோகம் மற்றும் தலைமைப் பொறுப்புகளில் வெற்றி.',
    'Jupiter_Mercury': 'உயர்கல்வி, கற்பித்தல், ஆலோசனை, வங்கி மற்றும் நிதித்துறை சார்ந்த பணிகளில் தனித்துவமான அறிவுத்திறன் வெளிப்படும்.',
    'Jupiter_Venus': 'குரு-சுக்கிர சேர்க்கை. பெரும் தன வரவு, மகிழ்ச்சியான குடும்ப வாழ்வு, ஆபரண யோகம் மற்றும் கலை ஈடுபாடு.',
    'Jupiter_Rahu': 'குரு சண்டாள நாடி அம்சம். மரபுசாரா நவீன அறிவு, புதிய உத்திகள் மற்றும் வெளிநாட்டுப் பயணங்களால் ஆதாயம்.',
    'Jupiter_Ketu': 'ஞானகாரக யோகம். ஆன்மீகம், வேத சாஸ்திரங்கள், ஆராய்ச்சி மற்றும் மனிதநேய பணிகளில் ஆழ்ந்த ஈடுபாடு.',

    // Saturn Combinations (Karma Karaka)
    'Saturn_Jupiter': 'தொழிலில் நீதி, நேர்மை மற்றும் தெய்வீக உதவி. கடின உழைப்பிற்கு ஏற்ற நிலையான நற்பலன்கள் கிட்டும்.',
    'Saturn_Venus': 'தொழிலில் தன லாபம், அழகுசாதனம், ஆடை, வாகனம் மற்றும் வர்த்தகம் சார்ந்த துறைகளில் நல்ல வளர்ச்சி.',
    'Saturn_Mercury': 'கணக்கு, வர்த்தகம், கணிதம், மென்பொருள் மற்றும் தொழில்நுட்ப பணிகளில் நுட்பமான வேலைத்திறன்.',
    'Saturn_Mars': 'தொழிற்சாலை, இயந்திரங்கள், கட்டுமானத்துறை மற்றும் பாதுகாப்புப் பணிகளில் உழைப்பின் மூலம் படிப்படியான முன்னேற்றம்.',
    'Saturn_Rahu': 'வெளிநாட்டு தொழில் தொடர்புகள், நவீன தொழில்நுட்பம் மற்றும் இயந்திரத் துறைகளில் விரைவான முன்னேற்றம்.',
    'Saturn_Ketu': 'தொழிலில் துறவு மனப்பான்மை, சேவை சார்ந்த பணிகள், மருத்துவம், சட்டம் மற்றும் மூலிகை ஆராய்ச்சியில் ஈடுபாடு.',

    // Venus Combinations (Kalathra & Dhana Karaka)
    'Venus_Mars': 'களத்திர-பூமி யோகம். துணைவர் வழியில் செல்வாக்கு, வீடு-மனை சேர்க்கை மற்றும் வசீகரமான கலை ஈடுபாடு.',
    'Venus_Jupiter': 'மகாலட்சுமி யோகம். செல்வ வளம், நிம்மதியான சுகபோக வாழ்வு, நற்குணங்கள் நிறைந்த வாழ்க்கைத்துணை.',
    'Venus_Mercury': 'பேச்சு சாதுரியம், வணிகத் திறமை, நகைச்சுவை உணர்வு மற்றும் அழகு கலைகளில் சிறந்த ஈடுபாடு.',
    'Venus_Saturn': 'கடின உழைப்பிற்குப் பின் அமைதியான செல்வ நிலை, பாரம்பரிய தொழிலில் ஈடுபாடு.',
    'Venus_Rahu': 'திரைத்துறை, நவீன ஆடம்பர வாழ்க்கை, வெளிநாட்டு வர்த்தகம் மற்றும் சொகுசு வாகனங்கள் வாங்கும் யோகம்.',
    'Venus_Ketu': 'கலைகளில் பக்தி மார்க்கம், எளிமையான மனநிலை, ஆடம்பரத்தை விட உள்ளத்து அமைதியை விரும்புதல்.',

    // Mars Combinations
    'Mars_Jupiter': 'தர்ம வீரம், சட்ட நீதி நேர்மை, தலைமைப்பண்பு மற்றும் சகோதரர்களால் உயர்வு.',
    'Mars_Venus': 'தொழில் முனைவு, வீடு-வாகனம் அமைதல் மற்றும் குடும்பத்தில் உற்சாகமான சூழல்.',
    'Mars_Saturn': 'தொழில் உழைப்பில் உறுதி, சவால்களை தாண்டி வெற்றிபெறும் மனத்திட்பம்.',
    'Mars_Rahu': 'தீவிரமான செயல்வேகம், பொறியியல் மற்றும் நவீன உபகரணங்களில் தேர்ச்சி.',
    'Mars_Ketu': 'அறுவைசிகிச்சை, துல்லியமான தொழில்நுட்பம், பாதுகாப்பு மற்றும் ஆன்மீக நெறியில் உறுதி.',
  };

  /// Generate deterministic interpretation based on source, target, relation, and direction
  static String getInterpretation({
    required String sourceKey,
    required String targetKey,
    required String sourceNameTa,
    required String targetNameTa,
    required int relativeHouse,
    required BnnMethod1DirectionGroup directionGroup,
    required BnnMethod1Relation relation,
    required List<String> targetKarakatwas,
  }) {
    final pairKey = "${sourceKey}_$targetKey";
    final specific = _specificCombinations[pairKey];

    final karakatwaSnippet = targetKarakatwas.take(3).join(', ');

    final buffer = StringBuffer();

    if (specific != null) {
      buffer.writeln(specific);
    } else {
      buffer.writeln(
        '$sourceNameTa மற்றும் $targetNameTa நாடி சேர்க்கை (${relation.labelTa}). '
        '$targetNameTa-வின் முக்கிய காரகத்துவங்களான $karakatwaSnippet ஆகியவை இந்த தொடர்பின் மூலம் தூண்டப்படுகின்றன.',
      );
    }

    // Directional contextual guidance
    switch (directionGroup) {
      case BnnMethod1DirectionGroup.trine159:
        buffer.write(' [திரிகோண திசை (1, 5, 9): இது பூர்வ புண்ணிய பலன்களை நேரடியாக இயக்கும் முதன்மை தொடர்பு].');
        break;
      case BnnMethod1DirectionGroup.upachaya311:
        buffer.write(' [உபசய திசை (3, 11): தொடர் முயற்சியினாலும் நல்வாய்ப்புகளினாலும் லாபத்தை உருவாக்கும் தொடர்பு].');
        break;
      case BnnMethod1DirectionGroup.seventh7:
        buffer.write(' [நேரெதிர் திசை (7): வாழ்க்கைத்துணை, வெளி உலகம் மற்றும் கூட்டுறவில் சமநிலையை கோரும் தொடர்பு].');
        break;
      case BnnMethod1DirectionGroup.second2:
        buffer.write(' [முன்னோக்கு திசை (2): தன வரவு மற்றும் அடுத்தகட்ட வாழ்வியல் செயல்பாடுகளை இயக்கும் தொடர்பு].');
        break;
      case BnnMethod1DirectionGroup.twelfth12:
        buffer.write(' [பின்னோக்கு திசை (12): கடந்த கால அனுபவங்கள், செலவுகள் மற்றும் ஆன்மீக பக்குவத்தை உணர்த்தும் தொடர்பு].');
        break;
    }

    return buffer.toString();
  }
}
