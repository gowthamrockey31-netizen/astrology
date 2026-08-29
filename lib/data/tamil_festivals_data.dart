import '../models/tamil_calendar_models.dart';

/// Isolated repository of Festivals categorized by religion/tradition
class TamilFestivalData {
  static final List<FestivalItem> _festivalList = [
    // --- 2025 ---
    const FestivalItem(year: 2025, month: 1, day: 1, nameTa: 'ஆங்கிலப் புத்தாண்டு', nameEn: 'New Year', category: FestivalCategory.national),
    const FestivalItem(year: 2025, month: 1, day: 10, nameTa: 'வைகுண்ட ஏகாதசி', nameEn: 'Vaikunta Ekadasi', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 1, day: 13, nameTa: 'போகிப் பண்டிகை', nameEn: 'Bhogi Festival', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 1, day: 14, nameTa: 'தைப்பொங்கல்', nameEn: 'Thai Pongal', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 1, day: 15, nameTa: 'மாட்டுப் பொங்கல்', nameEn: 'Mattu Pongal', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 1, day: 16, nameTa: 'காணும் பொங்கல்', nameEn: 'Kaanum Pongal', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 1, day: 26, nameTa: 'குடியரசு தினம்', nameEn: 'Republic Day', category: FestivalCategory.national),
    const FestivalItem(year: 2025, month: 2, day: 11, nameTa: 'தைப்பூசம்', nameEn: 'Thaipusam', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 2, day: 26, nameTa: 'மகா சிவராத்திரி', nameEn: 'Maha Shivaratri', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 3, day: 14, nameTa: 'மாசி மகம் / ஹோலி', nameEn: 'Masi Magam / Holi', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 3, day: 30, nameTa: 'தெலுங்கு வருடப் பிறப்பு / ரம்ஜான்', nameEn: 'Ugadi / Eid-ul-Fitr', category: FestivalCategory.muslim),
    const FestivalItem(year: 2025, month: 4, day: 6, nameTa: 'ஸ்ரீ ராமநவமி', nameEn: 'Sri Rama Navami', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 4, day: 10, nameTa: 'மகாவீர் ஜெயந்தி', nameEn: 'Mahavir Jayanthi', category: FestivalCategory.jain),
    const FestivalItem(year: 2025, month: 4, day: 14, nameTa: 'தமிழ்ப் புத்தாண்டு (விஸ்வாசுவசு)', nameEn: 'Tamil New Year', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 4, day: 18, nameTa: 'புனித வெள்ளி', nameEn: 'Good Friday', category: FestivalCategory.christian),
    const FestivalItem(year: 2025, month: 4, day: 20, nameTa: 'ஈஸ்டர் பெருநாள்', nameEn: 'Easter Sunday', category: FestivalCategory.christian),
    const FestivalItem(year: 2025, month: 4, day: 30, nameTa: 'அட்சய திருதியை', nameEn: 'Akshaya Tritiya', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 5, day: 1, nameTa: 'மே தினம்', nameEn: 'May Day', category: FestivalCategory.national),
    const FestivalItem(year: 2025, month: 5, day: 12, nameTa: 'சித்ரா பௌர்ணமி / புத்த பூர்ணிமா', nameEn: 'Chitra Pournami / Buddha Purnima', category: FestivalCategory.buddhist),
    const FestivalItem(year: 2025, month: 6, day: 7, nameTa: 'பக்ரீத் (ஈத் அல்-அதா)', nameEn: 'Bakrid', category: FestivalCategory.muslim),
    const FestivalItem(year: 2025, month: 7, day: 6, nameTa: 'மொஹரம் பண்டிகை', nameEn: 'Muharram', category: FestivalCategory.muslim),
    const FestivalItem(year: 2025, month: 8, day: 3, nameTa: 'ஆடிப் பெருக்கு', nameEn: 'Aadi Perukku', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 8, day: 8, nameTa: 'வரலக்ஷ்மி விரதம்', nameEn: 'Varalakshmi Vratam', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 8, day: 15, nameTa: 'சுதந்திர தினம் / ஸ்ரீ கிருஷ்ண ஜெயந்தி', nameEn: 'Independence Day / Krishna Jayanthi', category: FestivalCategory.national),
    const FestivalItem(year: 2025, month: 8, day: 27, nameTa: 'விநாயகர் சதுர்த்தி', nameEn: 'Vinayaka Chaturthi', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 9, day: 5, nameTa: 'மிலாதுன் நபி', nameEn: 'Milad-un-Nabi', category: FestivalCategory.muslim),
    const FestivalItem(year: 2025, month: 9, day: 22, nameTa: 'நவராத்திரி ஆரம்பம்', nameEn: 'Navaratri Begins', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 10, day: 1, nameTa: 'சரஸ்வதி பூஜை / ஆயுத பூஜை', nameEn: 'Saraswathi Pooja', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 10, day: 2, nameTa: 'விஜயதசமி / காந்தி ஜெயந்தி', nameEn: 'Vijayadasami / Gandhi Jayanthi', category: FestivalCategory.national),
    const FestivalItem(year: 2025, month: 10, day: 20, nameTa: 'தீபாவளிப் பண்டிகை', nameEn: 'Deepavali', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 10, day: 22, nameTa: 'கேதார கௌரி விரதம்', nameEn: 'Kedara Gouri Vratam', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 10, day: 27, nameTa: 'கந்த சஷ்டி விரத சூரசம்ஹாரம்', nameEn: 'Soorasamharam', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 12, day: 4, nameTa: 'திருவண்ணாமலை கார்த்திகை தீபம்', nameEn: 'Karthigai Deepam', category: FestivalCategory.hindu),
    const FestivalItem(year: 2025, month: 12, day: 25, nameTa: 'கிறிஸ்துமஸ் பெருவிழா', nameEn: 'Christmas', category: FestivalCategory.christian),

    // --- 2026 ---
    const FestivalItem(year: 2026, month: 1, day: 1, nameTa: 'ஆங்கிலப் புத்தாண்டு', nameEn: 'New Year', category: FestivalCategory.national),
    const FestivalItem(year: 2026, month: 1, day: 13, nameTa: 'போகிப் பண்டிகை', nameEn: 'Bhogi Festival', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 1, day: 14, nameTa: 'தைப்பொங்கல் திருநாள்', nameEn: 'Thai Pongal', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 1, day: 15, nameTa: 'மாட்டுப் பொங்கல் / திருவள்ளுவர் தினம்', nameEn: 'Mattu Pongal / Thiruvalluvar Day', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 1, day: 16, nameTa: 'காணும் பொங்கல் / உழவர் திருநாள்', nameEn: 'Kaanum Pongal', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 1, day: 26, nameTa: 'குடியரசு தினம்', nameEn: 'Republic Day', category: FestivalCategory.national),
    const FestivalItem(year: 2026, month: 2, day: 1, nameTa: 'தைப்பூசம்', nameEn: 'Thaipusam', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 2, day: 15, nameTa: 'மகா சிவராத்திரி', nameEn: 'Maha Shivaratri', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 3, day: 3, nameTa: 'மாசி மகம் / ஹோலி', nameEn: 'Masi Magam / Holi', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 3, day: 19, nameTa: 'தெலுங்கு வருடப் பிறப்பு (உகாதி)', nameEn: 'Ugadi', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 3, day: 20, nameTa: 'ஈதுல் ஃபித்ர் (ரம்ஜான்)', nameEn: 'Eid-ul-Fitr', category: FestivalCategory.muslim),
    const FestivalItem(year: 2026, month: 3, day: 27, nameTa: 'ஸ்ரீ ராமநவமி', nameEn: 'Sri Rama Navami', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 3, day: 31, nameTa: 'மகாவீர் ஜெயந்தி', nameEn: 'Mahavir Jayanthi', category: FestivalCategory.jain),
    const FestivalItem(year: 2026, month: 4, day: 3, nameTa: 'புனித வெள்ளி', nameEn: 'Good Friday', category: FestivalCategory.christian),
    const FestivalItem(year: 2026, month: 4, day: 5, nameTa: 'ஈஸ்டர் பெருநாள்', nameEn: 'Easter Sunday', category: FestivalCategory.christian),
    const FestivalItem(year: 2026, month: 4, day: 14, nameTa: 'தமிழ்ப் புத்தாண்டு (பராபவ வருடம்)', nameEn: 'Tamil New Year', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 4, day: 19, nameTa: 'அட்சய திருதியை', nameEn: 'Akshaya Tritiya', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 5, day: 1, nameTa: 'மே தினம் / சித்ரா பௌர்ணமி', nameEn: 'May Day / Chitra Pournami', category: FestivalCategory.national),
    const FestivalItem(year: 2026, month: 5, day: 27, nameTa: 'பக்ரீத் பெருநாள்', nameEn: 'Bakrid', category: FestivalCategory.muslim),
    const FestivalItem(year: 2026, month: 5, day: 31, nameTa: 'புத்த பூர்ணிமா', nameEn: 'Buddha Purnima', category: FestivalCategory.buddhist),
    const FestivalItem(year: 2026, month: 6, day: 25, nameTa: 'மொஹரம் பண்டிகை', nameEn: 'Muharram', category: FestivalCategory.muslim),
    const FestivalItem(year: 2026, month: 8, day: 3, nameTa: 'ஆடிப் பெருக்கு', nameEn: 'Aadi Perukku', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 8, day: 15, nameTa: 'சுதந்திர தினம்', nameEn: 'Independence Day', category: FestivalCategory.national),
    const FestivalItem(year: 2026, month: 8, day: 25, nameTa: 'மிலாதுன் நபி', nameEn: 'Milad-un-Nabi', category: FestivalCategory.muslim),
    const FestivalItem(year: 2026, month: 8, day: 28, nameTa: 'வரலக்ஷ்மி விரதம்', nameEn: 'Varalakshmi Vratam', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 9, day: 4, nameTa: 'ஸ்ரீ கிருஷ்ண ஜெயந்தி (கோகுலாஷ்டமி)', nameEn: 'Krishna Jayanthi', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 9, day: 14, nameTa: 'விநாயகர் சதுர்த்தி', nameEn: 'Vinayaka Chaturthi', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 10, day: 2, nameTa: 'காந்தி ஜெயந்தி', nameEn: 'Gandhi Jayanthi', category: FestivalCategory.national),
    const FestivalItem(year: 2026, month: 10, day: 11, nameTa: 'நவராத்திரி ஆரம்பம்', nameEn: 'Navaratri Begins', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 10, day: 19, nameTa: 'சரஸ்வதி பூஜை / ஆயுத பூஜை', nameEn: 'Saraswathi Pooja', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 10, day: 20, nameTa: 'விஜயதசமி', nameEn: 'Vijayadasami', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 11, day: 8, nameTa: 'தீபாவளித் திருநாள்', nameEn: 'Deepavali', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 11, day: 15, nameTa: 'கந்த சஷ்டி சூரசம்ஹாரம்', nameEn: 'Soorasamharam', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 11, day: 23, nameTa: 'திருவண்ணாமலை மகா தீபம்', nameEn: 'Karthigai Deepam', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 12, day: 20, nameTa: 'வைகுண்ட ஏகாதசி', nameEn: 'Vaikunta Ekadasi', category: FestivalCategory.hindu),
    const FestivalItem(year: 2026, month: 12, day: 25, nameTa: 'கிறிஸ்துமஸ் பெருவிழா', nameEn: 'Christmas', category: FestivalCategory.christian),
    const FestivalItem(year: 2026, month: 12, day: 29, nameTa: 'ஆருத்ரா தரிசனம்', nameEn: 'Arudra Darisanam', category: FestivalCategory.hindu),

    // --- 2027 ---
    const FestivalItem(year: 2027, month: 1, day: 1, nameTa: 'ஆங்கிலப் புத்தாண்டு', nameEn: 'New Year', category: FestivalCategory.national),
    const FestivalItem(year: 2027, month: 1, day: 14, nameTa: 'தைப்பொங்கல்', nameEn: 'Thai Pongal', category: FestivalCategory.hindu),
    const FestivalItem(year: 2027, month: 1, day: 15, nameTa: 'மாட்டுப் பொங்கல்', nameEn: 'Mattu Pongal', category: FestivalCategory.hindu),
    const FestivalItem(year: 2027, month: 1, day: 16, nameTa: 'காணும் பொங்கல்', nameEn: 'Kaanum Pongal', category: FestivalCategory.hindu),
    const FestivalItem(year: 2027, month: 1, day: 22, nameTa: 'தைப்பூசம்', nameEn: 'Thaipusam', category: FestivalCategory.hindu),
    const FestivalItem(year: 2027, month: 1, day: 26, nameTa: 'குடியரசு தினம்', nameEn: 'Republic Day', category: FestivalCategory.national),
    const FestivalItem(year: 2027, month: 3, day: 6, nameTa: 'மகா சிவராத்திரி', nameEn: 'Maha Shivaratri', category: FestivalCategory.hindu),
    const FestivalItem(year: 2027, month: 3, day: 10, nameTa: 'ரம்ஜான் (ஈதுல் ஃபித்ர்)', nameEn: 'Eid-ul-Fitr', category: FestivalCategory.muslim),
    const FestivalItem(year: 2027, month: 3, day: 26, nameTa: 'புனித வெள்ளி', nameEn: 'Good Friday', category: FestivalCategory.christian),
    const FestivalItem(year: 2027, month: 4, day: 14, nameTa: 'தமிழ்ப் புத்தாண்டு (ப்ளவங்க)', nameEn: 'Tamil New Year', category: FestivalCategory.hindu),
    const FestivalItem(year: 2027, month: 5, day: 1, nameTa: 'மே தினம்', nameEn: 'May Day', category: FestivalCategory.national),
    const FestivalItem(year: 2027, month: 5, day: 17, nameTa: 'பக்ரீத்', nameEn: 'Bakrid', category: FestivalCategory.muslim),
    const FestivalItem(year: 2027, month: 8, day: 15, nameTa: 'சுதந்திர தினம்', nameEn: 'Independence Day', category: FestivalCategory.national),
    const FestivalItem(year: 2027, month: 9, day: 4, nameTa: 'விநாயகர் சதுர்த்தி', nameEn: 'Vinayaka Chaturthi', category: FestivalCategory.hindu),
    const FestivalItem(year: 2027, month: 10, day: 2, nameTa: 'காந்தி ஜெயந்தி', nameEn: 'Gandhi Jayanthi', category: FestivalCategory.national),
    const FestivalItem(year: 2027, month: 10, day: 9, nameTa: 'ஆயுத பூஜை', nameEn: 'Ayutha Pooja', category: FestivalCategory.hindu),
    const FestivalItem(year: 2027, month: 10, day: 10, nameTa: 'விஜயதசமி', nameEn: 'Vijayadasami', category: FestivalCategory.hindu),
    const FestivalItem(year: 2027, month: 10, day: 29, nameTa: 'தீபாவளி', nameEn: 'Deepavali', category: FestivalCategory.hindu),
    const FestivalItem(year: 2027, month: 12, day: 25, nameTa: 'கிறிஸ்துமஸ்', nameEn: 'Christmas', category: FestivalCategory.christian),
  ];

  /// Get festivals for a specific Date
  static List<FestivalItem> getFestivalsForDate(DateTime date) {
    return _festivalList.where((f) =>
      f.year == date.year &&
      f.month == date.month &&
      f.day == date.day
    ).toList();
  }

  /// Get all festivals for a specific year
  static List<FestivalItem> getFestivalsForYear(int year) {
    return _festivalList.where((f) => f.year == year).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
