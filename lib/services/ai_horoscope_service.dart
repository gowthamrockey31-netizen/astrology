enum HoroscopeLanguage {
  english,
  tamil,
}

class HoroscopeTopicAdvice {
  final String titleEn;
  final String titleTa;
  final String contentEn;
  final String contentTa;

  const HoroscopeTopicAdvice({
    required this.titleEn,
    required this.titleTa,
    required this.contentEn,
    required this.contentTa,
  });
}

class AiHoroscopeService {
  /// Quick suggestion chips for the UI
  static List<Map<String, String>> getQuickPrompts(HoroscopeLanguage lang) {
    if (lang == HoroscopeLanguage.tamil) {
      return [
        {'title': '💼 தொழில் & வேலை வாய்ப்பு', 'prompt': 'என் தொழில் மற்றும் வேலை வாய்ப்பு பலன்கள், உத்தியோக முன்னேற்றம் பற்றி கூறவும்.'},
        {'title': '💍 திருமண யோகம் & வரன்', 'prompt': 'எனக்கு திருமண யோகம் எப்போது கூடும்? களத்திர பலம் மற்றும் பொருத்தமான பரிகாரங்கள் என்ன?'},
        {'title': '💰 தன லாபம் & கடன் நிவர்த்தி', 'prompt': 'பொருளாதார வளர்ச்சி, தன லாபம் மற்றும் கடன் சுமைகள் நீங்க ஜோதிட ஆலோசனை கூறவும்.'},
        {'title': '🪐 சனி & குரு பெயர்ச்சி', 'prompt': 'நடப்பு சனி பெயர்ச்சி மற்றும் குரு பெயர்ச்சி கோச்சார பலன்கள் எவ்வாறு உள்ளன?'},
        {'title': '📜 நடப்பு தசா புக்தி பலன்', 'prompt': 'சுக்கிர தசை அல்லது நடப்பு தசா-புக்தி பலன்கள் மற்றும் செய்ய வேண்டிய வழிபாடுகள் என்ன?'},
        {'title': '💎 அதிர்ஷ்ட நவரத்தினம்', 'prompt': 'எனக்கு உகந்த அதிர்ஷ்ட நவரத்தினம், அதிர்ஷ்ட எண் மற்றும் நிறம் பற்றி வழிகாட்டவும்.'},
        {'title': '🏠 வாஸ்து ஆலோசனைகள்', 'prompt': 'வீட்டில் சுபமங்களமும் லட்சுமி கடாட்சமும் பெருக வாஸ்து ஆலோசனைகள் கூறவும்.'},
        {'title': '🩺 ஆரோக்கியம் & மன அமைதி', 'prompt': 'ஆரோக்கிய குறைபாடுகள் நீங்கி மன அமைதியும் நீண்ட ஆயுளும் பெற ஜோதிட வழிகாட்டுதல்.'},
        {'title': '♈ மேஷம் லக்னம் / கடக ராசி', 'prompt': 'மேஷ லக்னம் மற்றும் கடக ராசி பூச நட்சத்திரத்திற்குரிய பொது பலன்களும் யோகங்களும் என்ன?'},
      ];
    } else {
      return [
        {'title': '💼 Career & Job Growth', 'prompt': 'Guide me on career prospects, job promotion, and business growth according to Vedic astrology.'},
        {'title': '💍 Marriage & Compatibility', 'prompt': 'When will marriage happen? Tell me about 7th house alignment and partner compatibility.'},
        {'title': '💰 Wealth & Debt Relief', 'prompt': 'What are the astrological insights for financial prosperity, wealth accumulation, and clearing debts?'},
        {'title': '🪐 Saturn & Jupiter Transits', 'prompt': 'How will current Saturn (Shani) and Jupiter (Guru) transits influence my horoscope?'},
        {'title': '📜 Current Dasha-Bhukti', 'prompt': 'Explain the impact of Venus (Sukra) Mahadasha and recommended planetary prayers.'},
        {'title': '💎 Lucky Gemstone & Colors', 'prompt': 'Which gemstone, lucky numbers, and auspicious directions suit my horoscope best?'},
        {'title': '🏠 Vastu Shastra Tips', 'prompt': 'Share key Vastu Shastra principles for peace, prosperity, and wealth energy at home.'},
        {'title': '🩺 Health & Mental Peace', 'prompt': 'Astrological remedies for vitality, good health, and peace of mind.'},
      ];
    }
  }

  /// Initial Greeting Message
  static String getWelcomeMessage(HoroscopeLanguage lang) {
    if (lang == HoroscopeLanguage.tamil) {
      return 'வணக்கம்! நான் உங்கள் AI ஜோதிட வழிகாட்டி (AstroDashaCare AI Guru).\n\n'
          'உங்கள் ஜாதக கட்டம், கிரக நிலைகள், கோச்சாரம், நடப்பு தசா-புக்தி, தொழில் முன்னேற்றம், திருமண யோகம், தன லாபம், நவரத்தின பரிந்துரை, மற்றும் எளிய பரிகாரங்கள் பற்றி என்னிடம் கேளுங்கள்.';
    } else {
      return 'Namaste! I am your AI Astrological Assistant (AstroDashaCare AI Guru).\n\n'
          'Ask me about your Kundli transits, Dasha-Bhukti periods, Career growth, Marriage timing, Wealth yogas, Gemstone recommendations, or Daily horoscope advice.';
    }
  }

  /// Primary Advice Generator
  static String generateAdvice(String query, HoroscopeLanguage lang) {
    final lower = query.toLowerCase().trim();

    // 1. SPECIFIC BIRTH CHART / HOROSCOPE PARSING (e.g. Mesha Lagna, Kataka Rasi, Poosam, Sukra Dasa)
    if (_matchesAny(lower, ['மேஷம்', 'கடகம்', 'பூசம்', 'செந்தில்குமார்', 'mesha', 'kataka', 'cancer', 'aries', 'pushya', 'poosam'])) {
      return _generateBirthChartAdvice(lower, lang);
    }

    // 2. CAREER / JOB / PROMOTION / BUSINESS
    if (_matchesAny(lower, ['தொழில்', 'வேலை', 'உத்தியோகம்', 'வியாபாரம்', 'பதவி', 'அரசு', 'career', 'job', 'business', 'promotion', 'work', 'office'])) {
      return _generateCareerAdvice(lang);
    }

    // 3. MARRIAGE / LOVE / RELATIONSHIP / COMPATIBILITY
    if (_matchesAny(lower, ['திருமணம்', 'கல்யாணம்', 'காதல்', 'வரன்', 'பொருத்தம்', 'களத்திரம்', 'செவ்வாய் தோஷம்', 'marriage', 'love', 'relationship', 'partner', 'compatibility', 'spouse'])) {
      return _generateMarriageAdvice(lang);
    }

    // 4. WEALTH / MONEY / DEBT / FINANCE
    if (_matchesAny(lower, ['பணம்', 'செல்வம்', 'தனம்', 'லாபம்', 'கடன்', 'பொருளாதாரம்', 'சொத்து', 'money', 'wealth', 'finance', 'debt', 'loan', 'income', 'profit', 'rich'])) {
      return _generateWealthAdvice(lang);
    }

    // 5. PLANETARY TRANSITS / SHANI / GURU / RAHU KETU
    if (_matchesAny(lower, ['சனி', 'குரு', 'ராகு', 'கேது', 'பெயர்ச்சி', 'கோச்சாரம்', 'ஏழரை', 'saturn', 'shani', 'jupiter', 'guru', 'transit', 'sade sati', 'rahu', 'ketu'])) {
      return _generateTransitAdvice(lower, lang);
    }

    // 6. DASHA - BHUKTI (சுக்கிர தசை, சனி தசை, குரு தசை)
    if (_matchesAny(lower, ['தசா', 'தசை', 'புக்தி', 'சுக்கிரன்', 'dasha', 'dasa', 'bhukti', 'venus', 'sukra'])) {
      return _generateDashaAdvice(lower, lang);
    }

    // 7. GEMSTONES & LUCKY ELEMENTS
    if (_matchesAny(lower, ['ரத்தினம்', 'நவரத்தினம்', 'மாணிக்கம்', 'முத்து', 'பவளம்', 'மரகதம்', 'புஷ்பராகம்', 'வைரம்', 'நீலம்', 'gemstone', 'stone', 'diamond', 'sapphire', 'pearl', 'ruby', 'emerald'])) {
      return _generateGemstoneAdvice(lang);
    }

    // 8. VASTU SHASTRA
    if (_matchesAny(lower, ['வாஸ்து', 'வீடு', 'திசை', 'ஈசானியம்', 'குபேர', 'vastu', 'house', 'direction', 'entrance', 'room'])) {
      return _generateVastuAdvice(lang);
    }

    // 9. HEALTH & LONGEVITY
    if (_matchesAny(lower, ['உடல்நலம்', 'ஆரோக்கியம்', 'நோய்', 'மருத்துவம்', 'ஆயுள்', 'health', 'disease', 'illness', 'fitness', 'mental peace'])) {
      return _generateHealthAdvice(lang);
    }

    // 10. EDUCATION & EXAMS
    if (_matchesAny(lower, ['கல்வி', 'படிப்பு', 'தேர்வு', 'பள்ளி', 'கல்லூரி', 'education', 'study', 'studies', 'exam', 'student'])) {
      return _generateEducationAdvice(lang);
    }

    // 11. GENERAL / RASIS
    return _generateGeneralVedicAdvice(query, lang);
  }

  /// Specific Horoscope Analysis (Based on user birth chart provided)
  static String _generateBirthChartAdvice(String query, HoroscopeLanguage lang) {
    if (lang == HoroscopeLanguage.tamil) {
      return '''🌟 மேஷ லக்னம் - கடக ராசி (பூசம் நட்சத்திரம்) ஜாதக கணிப்பு:

🔮 கிரக நிலைகள் & லக்ன பலம்:
• லக்னாதிபதி செவ்வாய் லக்னத்திலேயே ஆட்சி பலம் (பரணி-2) பெற்று "ருச்சக யோகம்" போன்ற மிகுந்த தைரியத்தையும், தலைமை தாங்கும் ஆற்றலையும் அளிக்கிறார்.
• ராசி நாதன் சந்திரன் தனது சொந்த வீடான கடகத்தில் ஆட்சி பெற்று அமைந்திருப்பது சிறந்த மன வலிமையையும், தாய் வழி ஆசிகளையும் சுட்டிக்காட்டுகிறது.
• 11-ம் இடமான லாப ஸ்தானத்தில் புதன்(வ) - குரு பார்வை மற்றும் ராகு சேர்க்கை இருப்பது எதிர்பாராத பொருளாதார வரவுகளையும், அறிவுசார் வருமானத்தையும் தரும்.

📜 நடப்பு சுக்கிர தசா - சுக்கிர புக்தி வழிகாட்டல்:
• சுக்கிரன் மகரத்தில் (10-ம் பாவ தொடர்பு) அமர்ந்து தொழில் காரகனாக விளங்குவதால், சுப காரியங்கள், வண்டி வாகனம், மற்றும் கலை/வியாபார விருத்தி ஏற்படும்.
• 2028 வரை சுக்கிர புக்தி நடப்பில் இருப்பதால் குடும்பத்தில் அமைதியும், பொருளாதார ஸ்திரத்தன்மையும் உருவாகும்.

📿 பரிந்துரைக்கப்படும் எளிய பரிகாரங்கள்:
1. செவ்வாய்க்கிழமை தோறும் முருகப் பெருமானுக்கு செவ்வரளி மலர் சாற்றி நெய்தீபம் ஏற்றுவது லக்ன பலத்தை அதிகரிக்கும்.
2. திங்கட்கிழமை சிவபெருமானுக்கு பால் அல்லது இளநீர் அபிஷேகம் செய்து வழிபடுவது மன நிம்மதியைத் தரும்.
3. வெள்ளிக்கிழமைகளில் மகாலட்சுமிக்கு நெய் தீபமேற்றி கனகதாரா ஸ்தோத்திரம் கேட்பது சுக்கிர தசை யோகத்தை முழுமையாகத் தரும்.

💎 அதிர்ஷ்டக் குறிப்புகள்:
• உகந்த ரத்தினம்: பவளம் (Coral) மோதிர விரலில் அல்லது வெள்ளை புஷ்பராகம் / வைரம்.
• அதிர்ஷ்ட எண்கள்: 9, 6, 1 | அதிர்ஷ்ட கிழமைகள்: செவ்வாய், வெள்ளி.''';
    } else {
      return '''🌟 Horoscope Analysis: Aries Ascendant (Mesha Lagna) - Cancer Moon (Pushya Nakshatra)

🔮 Planetary Strengths & Insights:
• Ascendant Lord Mars is strongly placed in the 1st house (Bharani-2) in its own sign Aries, forming Ruchaka-like courage, dynamic drive, and leadership qualities.
• Moon, your Rasi Lord, is situated in Cancer (Pushya-1) in its own sign, granting strong emotional resilience, maternal blessings, and intuitive wisdom.
• Jupiter (exalted in transit/placed in 12th/11th house) and Mercury bring intellectual financial growth and wise investments.

📜 Current Venus (Sukra) Mahadasha Guidance:
• Venus positioned in Capricorn (10th/9th house influence) brings career prominence, material comforts, and auspicious ceremonies in the household.
• The current Venus-Venus period (lasting until late 2028) is highly auspicious for stabilizing assets, acquisitions, and creative ventures.

📿 Simple Vedic Remedies:
1. Lord Muruga / Kartikeya worship on Tuesdays with red flowers to harness Mars energy.
2. Shiva Abhishekam on Mondays with milk for mental clarity and peace (Moon blessings).
3. Light a cow ghee lamp on Friday evenings dedicated to Goddess Mahalakshmi.

💎 Lucky Elements:
• Favorable Gemstone: Red Coral (Pavazham) on ring finger, or White Zircon/Diamond.
• Lucky Numbers: 9, 6, 1 | Lucky Days: Tuesday, Friday.''';
    }
  }

  /// Career Advice
  static String _generateCareerAdvice(HoroscopeLanguage lang) {
    if (lang == HoroscopeLanguage.tamil) {
      return '''💼 தொழில் மற்றும் உத்தியோக ஜோதிட வழிகாட்டல்:

🔮 கிரக நிலைகள் & 10-ம் பாவக பார்வை:
• உங்கள் கர்ம ஸ்தானமான 10-ம் பாவகத்தில் சுப கிரகங்களின் பார்வை தொழில் நிலைத்தன்மையையும், புதிய வாய்ப்புகளையும் குறிக்கிறது.
• சனி பகவானின் காரகத்துவம் மற்றும் புதனின் புத்தி கூர்மை உங்களை நிர்வாகம், தொழில்நுட்பம், வியாபாரம் அல்லது ஆலோசனை துறைகளில் பிரகாசிக்க வைக்கும்.

📜 தொழில் முன்னேற்றத்திற்கான ஆலோசனைகள்:
• அவசரப்பட்டு பெரிய முதலீடுகள் செய்வதை தவிர்த்து, திட்டமிட்டு விரிவாக்கம் செய்யவும்.
• மேலதிகாரிகள் மற்றும் சக ஊழியர்களிடம் இணக்கமான அணுகுமுறையை கடைப்பிடிப்பது பதவி உயர்வை விரைவுபடுத்தும்.
• கூட்டுத் தொழில் செய்வோர் கணக்கு வழக்குகளில் வெளிப்படைத்தன்மையுடன் இருப்பது அவசியம்.

📿 தொழில் வளர்ச்சி தரும் எளிய பரிகாரங்கள்:
1. சனிக்கிழமைகளில் நல்லெண்ணெய் தீபம் ஏற்றி ஆஞ்சநேயர் அல்லது சனி பகவானை வழிபடுவது பணியில் தடைகளை நீக்கும்.
2. வியாழக்கிழமைகளில் தட்சிணாமூர்த்திக்கு மஞ்சள் வஸ்திரம் சாற்றி வழிபட பணி உயர்வு கிட்டும்.
3. அலுவலக மேசையில் அல்லது கல்லாப்பெட்டியில் பச்சை கற்பூரம் மற்றும் ஏலக்காய் வைப்பது வியாபார வசியத்தை உண்டாக்கும்.

💎 அதிர்ஷ்டக் குறிப்பு:
• தொழில் வெற்றி தரும் கிழமை: வியாழன், புதன்.
• உகந்த நிறம்: பச்சை, வெளிர் மஞ்சள்.''';
    } else {
      return '''💼 Career & Professional Astrological Guidance:

🔮 Planetary Alignments & 10th House:
• Benefic influences on the 10th house (Karma Bhava) indicate positive momentum in career endeavors and recognition.
• Saturn’s discipline combined with Mercury’s intellect favors management, consulting, trade, technology, and leadership roles.

📜 Actionable Career Advice:
• Focus on long-term strategy rather than impulsive career shifts; stability rewards you now.
• Clear communication with mentors and seniors will pave the path for promotions and salary hikes.
• If involved in business partnerships, ensure documented clarity in transactions.

📿 Vedic Remedies for Career Success:
1. Offer sesame oil lamps to Lord Hanuman or Shani Dev on Saturdays to dissolve career obstacles.
2. Chant "Om Guruve Namaha" on Thursdays and offer yellow flowers to Lord Dakshinamurthy.
3. Keep natural camphor and cardamom in your work area to attract positive business vibrations.

💎 Lucky Indicators:
• Auspicious Days: Wednesday, Thursday | Favorable Color: Emerald Green, Light Gold.''';
    }
  }

  /// Marriage Advice
  static String _generateMarriageAdvice(HoroscopeLanguage lang) {
    if (lang == HoroscopeLanguage.tamil) {
      return '''💍 திருமண யோகம் & களத்திர பலன்:

🔮 7-ம் பாவக பலன் & சுக்கிர அருள்:
• களத்திர ஸ்தானமான 7-ம் வீடு மற்றும் களத்திர காரகரான சுக்கிரனின் பலம் திருமண அமைப்பை தீர்மானிக்கிறது.
• குரு பகவானின் பார்வை லக்னத்தையோ அல்லது 7-ம் வீட்டையோ கடக்கும் காலத்தில் விவாக யோகம் மிகச் சிறப்பாக கைகூடும் ("குரு பார்க்க கோடி நன்மை").

📜 திருமண வழிகாட்டுதல்:
• வரன் பார்க்கும் போது ஜாதகத்தில் ரஜ்ஜு பொருத்தம், தின பொருத்தம் மற்றும் மன பொருத்தம் ஆகியவற்றை முதன்மையாக கவனிக்கவும்.
• செவ்வாய் 2, 4, 7, 8, 12 ஆகிய இடங்களில் இருந்தால், அதே போன்ற சம தோஷமுள்ள ஜாதகங்களை இணைப்பது சிறந்த இல்லறத்தை அமைக்கும்.

📿 திருமண தடை நீங்க எளிய பரிகாரங்கள்:
1. வெள்ளிக்கிழமைகளில் அம்பாள் சன்னதியில் நெய் தீபமேற்றி லலிதா சகஸ்ரநாமம் அல்லது அம்மன் துதி பாராயணம் செய்யவும்.
2. செவ்வாய்க்கிழமைகளில் துர்க்கை அம்மனுக்கு எலுமிச்சை விளக்கு ஏற்றி வழிபட செவ்வாய் தோஷ தாக்கங்கள் தணியும்.
3. ஏழைப் பெண் திருமணத்திற்கு உங்களால் இயன்ற மங்களப் பொருட்களை (மாங்கல்ய தானம்/வஸ்திரம்) தானம் அளிப்பது மிகச் சிறந்த பலனைத் தரும்.

💎 அதிர்ஷ்டக் குறிப்பு:
• வழிபட வேண்டிய தெய்வம்: அன்னை பார்வதி மற்றும் கல்யாண சுந்தரேஸ்வரர்.''';
    } else {
      return '''💍 Marriage & Relationship Astrological Insights:

🔮 7th House & Venus (Kalathra Karaka):
• The 7th house governs matrimonial alliances, harmony, and partnerships. Venus signifies relationship quality and romance.
• Favorable transit of Jupiter (Guru Drishti) over the natal Moon or 7th house brings prompt matrimonial prospects and auspicious ceremonies.

📜 Matrimonial Guidance:
• Ensure harmony in Manglik (Kuja Dosha) factors and Nadi/Rajju compatibility before finalizing matches.
• Emotional understanding and patience are key during minor transitory testing periods.

📿 Remedies for Harmonious Marriage:
1. Light pure ghee lamps on Fridays before Goddess Parvati / Mahalakshmi.
2. Worship Goddess Durga with lemon lamps on Tuesday Rahu Kalam to soften planetary afflictions.
3. Donate clothing or sweets to elderly couples or contribute to a needy couple's wedding.

💎 Auspicious Direction & Deity:
• Primary Deity: Sri Kalyana Sundareswarar & Goddess Meenakshi.''';
    }
  }

  /// Wealth Advice
  static String _generateWealthAdvice(HoroscopeLanguage lang) {
    if (lang == HoroscopeLanguage.tamil) {
      return '''💰 தன லாபம், செல்வம் & கடன் நிவர்த்தி ஆலோசனை:

🔮 2-ம் & 11-ம் பாவக பலன் (தன - லாப ஸ்தானம்):
• 2-ம் பாவகம் குடும்பம், வாக்கு மற்றும் பண வரவையும், 11-ம் பாவகம் தொழில் லாபம் மற்றும் ஆசை நிறைவேற்றத்தையும் குறிக்கிறது.
• தன காரகரான குரு பகவானின் ஆசியும், லக்ஷ்மி காரகரான சுக்கிரனின் பலமும் செல்வ செழிப்பை நிலைநிறுத்தும்.

📜 பொருளாதார ஸ்திரத்தன்மைக்கான ஆலோசனைகள்:
• தேவையில்லாத விரயங்களை தவிர்த்து, தங்கம், நிலம் அல்லது நீண்ட கால சேமிப்புகளில் முதலீடு செய்வது நலம்.
• கடன் சுமை உள்ளவர்கள் செவ்வாய் ஓரை அல்லது செவ்வாய்க்கிழமைகளில் முதல் தவணையை திருப்பிச் செலுத்துவது கடனை விரைவில் அடைக்கும் ("ருண விமோசனம்").

📿 தன வசிய எளிய பரிகாரங்கள்:
1. தினமும் அல்லது வெள்ளிக்கிழமை மாலை வேளையில் வீட்டில் நெய் தீபமேற்றி "ஸ்ரீ கனகதாரா ஸ்தோத்திரம்" ஒலிக்கச் செய்யவும்.
2. வீட்டின் வடகிழக்கு (ஈசானியம்) பகுதியை எப்போதும் சுத்தமாகவும், சுமை இல்லாமலும் வைக்கவும்; வடக்கு திசையில் குபேரர் படம் வைத்து வழிபடலாம்.
3. செவ்வாய்க்கிழமைகளில் ருணவிமோசன லிங்கேஸ்வரர் வழிபாடு கடன் தொல்லைகளை நீக்கும்.

💎 அதிர்ஷ்டக் குறிப்பு:
• பணப்பெட்டி வைக்க உகந்த திசை: தென்மேற்கு (குபேர மூலை), வடக்கு நோக்கி திறக்குமாறு அமைக்கவும்.''';
    } else {
      return '''💰 Wealth, Prosperity & Debt Relief Guidance:

🔮 2nd & 11th House Dynamics:
• The 2nd house governs liquid finances, savings, and assets, while the 11th house controls gains, profits, and fulfillment of desires.
• Jupiter (Dhana Karaka) and Venus (Lakshmi Karaka) ensure uninterrupted wealth flow when auspiciously aligned.

📜 Financial Prosperity Strategies:
• Avoid speculative high-risk bets; channel funds toward long-term real estate, gold, and secure dividend instruments.
• To quickly liquidate debts, pay the first repayment installment during Mars Hora on Tuesdays ("Rina Vimochana").

📿 Remedies for Abundance:
1. Chant Sri Kanakadhara Stotram on Friday evenings with a cow ghee lamp.
2. Maintain the North-East (Ishanya) zone clutter-free to invite cosmic wealth vibrations.
3. Place your cash box in the South-West corner facing North towards Lord Kubera.

💎 Lucky Wealth Color: Golden Yellow, Off-White.''';
    }
  }

  /// Transits Advice
  static String _generateTransitAdvice(String query, HoroscopeLanguage lang) {
    if (lang == HoroscopeLanguage.tamil) {
      return '''🪐 முக்கிய கிரகப் பெயர்ச்சி (கோச்சார) பலன்கள்:

🔮 சனி பெயர்ச்சி பலன் (சனி பகவான் பார்வை):
• சனி பகவான் நீதிமான்; உங்கள் ஒழுக்கம், கடின உழைப்பு மற்றும் தர்ம சிந்தனைக்கேற்ப பலன்களை வாரி வழங்குவார்.
• ஏழரை சனி அல்லது அஷ்டம சனி நடப்பவர்கள் அச்சப்பட வேண்டியதில்லை; இது மனிதனை பக்குவப்படுத்தி உயர் நிலைக்கு அழைத்துச் செல்லும் காலமாகும்.

🔮 குரு பெயர்ச்சி & ராகு-கேது பெயர்ச்சி:
• குருவின் பார்வை படும் இடங்கள் தோஷ நிவர்த்தி பெற்று சுப காரியங்களை உண்டாக்கும்.
• ராகு-கேது கோச்சாரம் ஆன்மீக நாட்டம், வெளிநாட்டு தொடர்புகள் மற்றும் தீடீர் மாற்றங்களை உருவாக்கும்.

📿 பெயர்ச்சி தோஷ நிவாரண பரிகாரங்கள்:
1. சனிக்கிழமைகளில் காக்கைக்கு எள் கலந்த சாதம் வைப்பது மற்றும் மாற்றுத்திறனாளிகளுக்கு அன்னதானம் செய்வது சனி ப்ரீதியை உண்டாக்கும்.
2. வியாழக்கிழமை கொண்டைக்கடலை மாலை சாற்றி குரு தட்சிணாமூர்த்தியை வழிபட குரு பலம் கூடும்.
3. சங்கடஹர சதுர்த்தியன்று விநாயகருக்கு அருகம்புல் சாற்றி வழிபட ராகு-கேது தோஷங்கள் விலகும்.

💎 திருத்தல வழிகாட்டல்: திருநள்ளாறு தர்ப்பாரண்யேஸ்வரர், ஆலங்குடி குரு ஸ்தலம் மற்றும் திருநாகேஸ்வரம்.''';
    } else {
      return '''🪐 Major Planetary Transits (Gocharam) Insights:

🔮 Saturn (Shani) Influence:
• Shani rewards perseverance, truthfulness, and selfless deeds. Even during Sade Sati or Ashtama Shani, sincere efforts yield solid long-term foundations.

🔮 Jupiter (Guru) & Rahu-Ketu Transits:
• Jupiter’s divine aspect (Guru Drishti) neutralizes afflictions, opening gates for marriage, child birth, and spiritual wisdom.
• Rahu and Ketu stimulate intuitive evolution, foreign connections, and sudden transformative opportunities.

📿 Planetary Pacification Remedies:
1. Feed crows with sesame-mixed cooked rice on Saturday mornings to pacify Saturn.
2. Offer chickpea garlands and light ghee lamps to Lord Dakshinamurthy on Thursdays.
3. Worship Lord Ganesha with Durva grass on Sankashti Chaturthi to harmonize Rahu-Ketu transits.

💎 Sacred Pilgrim Centers: Thirunallar, Alangudi, and Thirunageswaram.''';
    }
  }

  /// Dasha Advice
  static String _generateDashaAdvice(String query, HoroscopeLanguage lang) {
    if (lang == HoroscopeLanguage.tamil) {
      return '''📜 நடப்பு தசா - புக்தி வழிகாட்டல் (சுக்கிர தசை & முக்கிய தசைகள்):

🔮 சுக்கிர தசை (20 வருட காலம்):
• சுக்கிரன் யோககாரகனாக அமையும் போது வீடு, நிலம், வாகனம், ஆடை ஆபரணங்கள், கலை ஆர்வம் மற்றும் குடும்பத்தில் மகிழ்ச்சியை வாரி வழங்குவார்.
• நடப்பு சுக்கிர புக்தி காலத்தில் கலைநயமிக்க பொருட்கள் சேர்க்கை மற்றும் நல்வாய்ப்புகள் உண்டாகும்.

📜 தசா காலத்தில் கவனிக்க வேண்டியவை:
• அளவுக்கு அதிகமான ஆடம்பர செலவுகளை கட்டுப்படுத்தி, நற்பணிகளுக்கு செலவிடுவது தசா பலனை பன்மடங்கு பெருக்கும்.
• பெண்கள் மற்றும் தாய்மார்களை மதித்து நடப்பது சுக்கிரனின் அருளை முழுமையாகப் பெற்றுத் தரும்.

📿 சுக்கிர தசா சிறப்பு பரிகாரங்கள்:
1. வெள்ளிக்கிழமைகளில் மகாலட்சுமி அஷ்டோத்திரம் சொல்லி துளசி அல்லது மல்லிகைப் பூவால் அர்ச்சிப்பது உத்தமம்.
2. வெள்ளை நிற மொச்சை தானியம் சுண்டல் செய்து அம்பாளுக்கு நைவேத்தியம் செய்து தானம் வழங்கவும்.
3. ஸ்ரீரங்கம் ரங்கநாதர் அல்லது கஞ்சனூர் சுக்கிர ஸ்தல வழிபாடு அளப்பரிய யோகங்களைத் தரும்.

💎 அதிர்ஷ்ட உலோகம் & ரத்தினம்: வெள்ளி, வைரம் அல்லது வெள்ளைக் கல்.''';
    } else {
      return '''📜 Mahadasha & Antardasha Guidance (Venus / Sukra Period):

🔮 Venus (Sukra) Mahadasha (20-Year Phase):
• As the planet of luxury, art, vehicles, relationships, and refinement, a well-placed Venus brings profound prosperity, material acquisitions, and marital joy.
• Current Venus Bhukti offers favorable conditions for aesthetic projects, real estate improvements, and domestic bliss.

📜 Core Principles to Maximize Dasha Blessings:
• Respect women, mothers, and artisans; honoring feminine divine energy directly elevates Venus strength.
• Direct surplus wealth toward sacred charity and noble causes to prevent unnecessary lavish dissipation.

📿 Sacred Remedies for Venus Dasha:
1. Chant Sri Lakshmi Ashtottara Shatanamavali on Friday mornings.
2. Offer white field beans (Mochai) naivedyam and distribute to devotees.
3. Visit Kanjanur Agneeswarar (Sukran Sthalam) or Srirangam Ranganatha Temple.

💎 Favorable Metal & Gem: Pure Silver, Diamond / White Zircon.''';
    }
  }

  /// Gemstone Advice
  static String _generateGemstoneAdvice(HoroscopeLanguage lang) {
    if (lang == HoroscopeLanguage.tamil) {
      return '''💎 அதிர்ஷ்ட நவரத்தின பரிந்துரை & வழிகாட்டல்:

🔮 நவரத்தின விபரங்கள்:
• சூரியன் - மாணிக்கம் (Ruby) | தந்தை ஆசி, தலைமை பண்பு, அரசு யோகம்.
• சந்திரன் - முத்து (Pearl) | மன அமைதி, தாய் வழி பாசம், தெளிவான சிந்தனை.
• செவ்வாய் - பவளம் (Coral) | தைரியம், நில யோகம், ரத்த ஓட்ட சீர்மை (மேஷம், விருச்சிகம்).
• புதன் - மரகதம் (Emerald) | கல்வி, வியாபாரம், பேச்சுத்திறமை.
• குரு - மஞ்சள் புஷ்பராகம் (Yellow Sapphire) | ஆன்மீகம், புத்திர பாக்கியம், தன வளர்ச்சி.
• சுக்கிரன் - வைரம் / வெண் புஷ்பராகம் (Diamond/White Zircon) | இல்லற சுகம், அழகு, செல்வாக்கு.
• சனி - நீலக்கல் (Blue Sapphire) | தீர்க்காயுள், தொழில் ஸ்திரத்தன்மை.
• ராகு - கோமேதகம் (Hessonite) & கேது - வைடூரியம் (Cat’s Eye).

📜 ரத்தினம் அணியும் விதிமுறைகள்:
• எந்த ரத்தினத்தையும் அணிவதற்கு முன் சுத்தமான பசும்பால் மற்றும் கங்கை நீரில் கழுவி, அதற்குரிய மூல மந்திரத்தை 108 முறை ஜெபித்து சுப முகூர்த்தத்தில் வலது கை விரல்களில் அணிய வேண்டும்.''';
    } else {
      return '''💎 Lucky Navaratna Gemstone Consultation:

🔮 Primary Vedic Gemstones:
• Sun - Ruby (Manikkam): Leadership, vitality, government favor.
• Moon - Natural Pearl (Muthu): Mental serenity, memory, motherly blessings.
• Mars - Red Coral (Pavazham): Courage, real estate gains, vitality (Aries & Scorpio).
• Mercury - Emerald (Maragatham): Intellect, commerce, communication mastery.
• Jupiter - Yellow Sapphire (Pukhraj): Divine wisdom, progeny, boundless wealth.
• Venus - Diamond / White Sapphire: Luxury, marital bliss, aesthetic elegance.
• Saturn - Blue Sapphire (Neelam): Discipline, karmic protection, longevity.
• Rahu - Hessonite (Gomed) & Ketu - Cat’s Eye (Vaidooryam).

📜 Consecration Protocol:
• Cleanse the gem in unboiled cow milk and pure water on an auspicious day/hora. Chant the ruling planetary mantra 108 times before wearing on the recommended finger.''';
    }
  }

  /// Vastu Advice
  static String _generateVastuAdvice(HoroscopeLanguage lang) {
    if (lang == HoroscopeLanguage.tamil) {
      return '''🏠 இல்லத்தில் சுபமங்களம் பெருக வாஸ்து சாஸ்திர குறிப்புகள்:

🔮 முக்கியமான திசைகள் & பலன்கள்:
• ஈசானியம் (வடகிழக்கு): இறைவனின் இடம். இங்கு தண்ணீர் தொட்டி, பூஜை அறை அமைப்பது சிறப்பு. எக்காரணம் கொண்டும் குப்பையோ, கனமான பொருட்களோ வைக்கக் கூடாது.
• குபேர மூலை (தென்மேற்கு): பணப்பெட்டி, பீரோ மற்றும் எஜமானரின் படுக்கையறை அமைக்க உகந்த இடம். இது செல்வத்தை நிலையாக தங்க வைக்கும்.
• அக்னி மூலை (தென்கிழக்கு): சமையலறை அமைக்க வேண்டும். சமையல் செய்யும்போது கிழக்கு நோக்கி நின்று சமைப்பது குடும்ப ஆரோக்கியத்தை காக்கும்.
• வாயு மூலை (வடமேற்கு): விருந்தினர் அறை மற்றும் தானிய சேமிப்பிற்கு உகந்தது.

📜 எளிய வாஸ்து பரிகாரங்கள்:
1. தலைவாசலில் வெள்ளிக்கிழமைகளில் மாவிலை தோரணம் மற்றும் மஞ்சள்-குங்குமம் இடுவது துஷ்ட சக்திகளை விரட்டும்.
2. வீட்டின் வரவேற்பறையில் ஒரு சிறிய பாத்திரத்தில் நீர் ஊற்றி அதில் நறுமண மலர்களை மிதக்க விடுவது நேர்மறை ஆற்றலை ஈர்க்கும்.''';
    } else {
      return '''🏠 Vastu Shastra Guidelines for Home Harmony & Abundance:

🔮 Cardinal Directions & Energies:
• North-East (Ishanya): Divine Corner. Best for Puja Mandir, water fountain, or meditation space. Keep it pristine and light.
• South-West (Kubera Corner): Master bedroom and wealth safe. Heavy cupboards placed here ensure retention of wealth and emotional stability.
• South-East (Agni Corner): Ideal for kitchen. Cook facing East to absorb rising solar energy for family health.
• North-West (Vayu Corner): Best for guest rooms, storage, and dynamic movement.

📜 Practical Vastu Enhancements:
1. Fasten fresh mango leaf toran and apply turmeric/kumkum at the main threshold on Fridays.
2. Keep a brass Uruli filled with clean water and fresh fragrant flowers in the living foyer to draw cosmic prana.''';
    }
  }

  /// Health Advice
  static String _generateHealthAdvice(HoroscopeLanguage lang) {
    if (lang == HoroscopeLanguage.tamil) {
      return '''🩺 ஆரோக்கியம் & நீண்ட ஆயுள் ஜோதிட வழிகாட்டல்:

🔮 6-ம் பாவக பார்வை & சூரிய பலம்:
• ஜோதிடத்தில் 6-ம் பாவகம் ரோகம் (நோய்) மற்றும் எதிர்ப்புகளை குறிக்கிறது. லக்னாதிபதியும் சூரியனும் பலமாக இருக்கும் போது உடல் எதிர்ப்பு சக்தி அபரிமிதமாக இருக்கும்.

📿 நல்வாழ்வு தரும் ஆன்மீக பரிகாரங்கள்:
1. தினமும் அதிகாலை சூரிய நமஸ்காரம் செய்து "ஓம் சூர்யாய நமஹ" மந்திரம் சொல்லி தாமிர பாத்திர நீர் அருந்துவது இரத்த ஓட்டம் மற்றும் கண் பார்வையை காக்கும்.
2. தன்வந்திரி பகவானை வணங்குவதும் அல்லது சனிக்கிழமை நல்லெண்ணெய் குளியல் எடுப்பதும் நரம்பு மற்றும் எலும்பு ஆரோக்கியத்தை தரும்.
3. பசுமாட்டிற்கு அகத்திக்கீரை அல்லது பழங்கள் வழங்குவது உடற்பிணிகளை தீர்க்கும் சிறந்த தானமாகும்.''';
    } else {
      return '''🩺 Health, Vitality & Longevity Astrological Guidance:

🔮 6th House & Solar Radiance:
• The 6th house rules ailments and recuperation. When the Lagna Lord and the Sun (Atma Karaka) are strong, vitality and natural immunity remain robust.

📿 Holistic Spiritual Practices:
1. Practice early morning Surya Namaskar and chant "Aditya Hridaya Stotram" for cardiovascular and metabolic vigor.
2. Worship Lord Dhanvantari, the celestial physician, for quick recovery from recurring afflictions.
3. Feed cows fresh greens (Agathi keerai) or fruits on Saturdays to cleanse karmic health encumbrances.''';
    }
  }

  /// Education Advice
  static String _generateEducationAdvice(HoroscopeLanguage lang) {
    if (lang == HoroscopeLanguage.tamil) {
      return '''🎓 கல்வி, புத்தி கூர்மை & தேர்வு வெற்றி ஜோதிட ஆலோசனை:

🔮 புதன் & குரு ஆசி:
• கல்வி காரகன் புதன் மற்றும் ஞான காரகன் குரு ஆகியோரின் சுப பார்வை சிறந்த ஞாபக சக்தியையும், தேர்வுகளில் முதல் மதிப்பெண் பெறும் யோகத்தையும் நல்கும்.

📿 சரஸ்வதி கடாட்ச எளிய பரிகாரங்கள்:
1. தினமும் படிக்கும் முன் "ஓம் ஐம் வாக்தேவ்யை ச வித்மஹே காமராஜாய தீமஹி தன்னோ தேவி ப்ரசோதயாத்" என்ற சரஸ்வதி காயத்ரி மந்திரத்தை 11 முறை ஜபிக்கவும்.
2. புதன்கிழமைகளில் விநாயகருக்கு அருகம்புல் சாற்றி வழிபட புத்தி கூர்மை பெருகும்.
3. படிக்கும் மேசையை வடக்கு அல்லது கிழக்கு திசை நோக்கி வைத்து படிப்பது கவன சிதறலை தடுக்கும்.''';
    } else {
      return '''🎓 Education, Intellect & Exam Success Guidance:

🔮 Mercury & Jupiter Alignment:
• Mercury (Buddhi Karaka) governs memory, analytical acumen, and communication, while Jupiter (Gnana Karaka) bestows higher wisdom.

📿 Remedies for Scholarly Excellence:
1. Recite the Saraswati Gayatri Mantra 11 times before beginning study sessions.
2. Offer fresh Durva grass to Lord Ganesha on Wednesdays for sharp focus.
3. Arrange your study desk facing East or North to harness magnetic learning frequencies.''';
    }
  }

  /// General Vedic Advice Fallback
  static String _generateGeneralVedicAdvice(String query, HoroscopeLanguage lang) {
    if (lang == HoroscopeLanguage.tamil) {
      return '''🌟 வேத ஜோதிட வழிகாட்டுதல்:

🔮 கிரக நிலைகளின் பொதுக் கணிப்பு:
"$query" என்ற உங்கள் வினாவிற்கு ஜோதிட ரீதியான ஆலோசனை:
• மனித வாழ்க்கையில் நடக்கும் ஒவ்வொரு நிகழ்வும் பூர்வ புண்ணியம், நடப்பு தசா-புக்தி மற்றும் கோச்சார கிரக சஞ்சாரங்களை பொறுத்தே அமைகிறது.
• நவகிரகங்களின் அருளும், குலதெய்வ வழிபாடும் எப்பேர்ப்பட்ட கிரக தோஷங்களையும் குறைத்து நன்மைகளை வாரி வழங்கும்.

📿 அனைவருக்கும் பொதுவான எளிய ஆன்மீக பரிகாரங்கள்:
1. மாதந்தோறும் உங்கள் ஜென்ம நட்சத்திர நாளிலோ அல்லது பௌர்ணமி நாளிலோ குலதெய்வ கோவிலுக்கு சென்று நெய்தீபம் ஏற்றி வழிபடுவது குடும்பத்தில் அமைதியை நிலைநிறுத்தும்.
2. காகத்திற்கு தினமும் காலையில் முதல் உணவை வழங்குவதும், ஆதரவற்றோருக்கு உதவுவதும் சனியின் கொடுமைகளை அகற்றி நற்கதியை தரும்.
3. தினமும் காலை அல்லது மாலை வேளையில் வீட்டில் கந்த சஷ்டி கவசம் அல்லது விஷ்ணு சஹஸ்ரநாமம் பாராயணம் செய்வது சகல நன்மைகளையும் தரும்.''';
    } else {
      return '''🌟 Vedic Astrological Consultation:

🔮 Cosmic Overview for "$query":
• Every life phase is governed by past karmic merits (Poorva Punya), prevailing Mahadasha-Antardasha periods, and planetary transits.
• With sincere devotion to your Kuladevata (family deity) and disciplined lifestyle, even challenging planetary phases turn into spiritual triumphs.

📿 Universal Vedic Remedies:
1. Visit your family deity (Kuladeivam) temple or a local shrine on every Amavasya/Pournami with cow ghee lamps.
2. Offer the first portion of morning food to birds/crows and help the needy to soften malefic Saturn/Rahu influences.
3. Listen to or recite Vishnu Sahasranama or Sri Rudram to maintain energetic purity in your home.''';
    }
  }

  /// Translate an existing message between English and Tamil
  static String translateMessage(String text, HoroscopeLanguage targetLang) {
    if (targetLang == HoroscopeLanguage.tamil) {
      // If already contains Tamil characters, return as-is
      if (_containsTamil(text)) return text;
      // Re-generate in Tamil based on intent
      return generateAdvice(text, HoroscopeLanguage.tamil);
    } else {
      // If no Tamil characters, return as-is
      if (!_containsTamil(text)) return text;
      // Re-generate in English based on intent
      return generateAdvice(text, HoroscopeLanguage.english);
    }
  }

  static bool _containsTamil(String text) {
    return text.codeUnits.any((code) => code >= 0x0B80 && code <= 0x0BFF);
  }

  static bool _matchesAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k.toLowerCase()));
  }
}
