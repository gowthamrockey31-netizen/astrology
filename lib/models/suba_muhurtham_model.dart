class SubaMuhurthamModel {
  final String id;
  final String tamilDate;
  final String englishDate;
  final String dayOfWeek;
  final String tithi;
  final String nakshatra;
  final String yoga;
  final String muhurthamTime;
  final String lagna;
  final String description;
  final int displayOrder;
  final bool isActive;

  const SubaMuhurthamModel({
    required this.id,
    required this.tamilDate,
    required this.englishDate,
    required this.dayOfWeek,
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.muhurthamTime,
    required this.lagna,
    required this.description,
    this.displayOrder = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tamilDate': tamilDate,
      'englishDate': englishDate,
      'dayOfWeek': dayOfWeek,
      'tithi': tithi,
      'nakshatra': nakshatra,
      'yoga': yoga,
      'muhurthamTime': muhurthamTime,
      'lagna': lagna,
      'description': description,
      'displayOrder': displayOrder,
      'isActive': isActive,
    };
  }

  factory SubaMuhurthamModel.fromMap(Map<String, dynamic> map) {
    return SubaMuhurthamModel(
      id: map['id']?.toString() ?? '',
      tamilDate: map['tamilDate']?.toString() ?? '',
      englishDate: map['englishDate']?.toString() ?? '',
      dayOfWeek: map['dayOfWeek']?.toString() ?? '',
      tithi: map['tithi']?.toString() ?? '',
      nakshatra: map['nakshatra']?.toString() ?? '',
      yoga: map['yoga']?.toString() ?? '',
      muhurthamTime: map['muhurthamTime']?.toString() ?? '',
      lagna: map['lagna']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      displayOrder: (map['displayOrder'] is int)
          ? map['displayOrder']
          : int.tryParse(map['displayOrder']?.toString() ?? '0') ?? 0,
      isActive: map['isActive'] == null ? true : (map['isActive'] == true || map['isActive'] == 'true'),
    );
  }

  SubaMuhurthamModel copyWith({
    String? id,
    String? tamilDate,
    String? englishDate,
    String? dayOfWeek,
    String? tithi,
    String? nakshatra,
    String? yoga,
    String? muhurthamTime,
    String? lagna,
    String? description,
    int? displayOrder,
    bool? isActive,
  }) {
    return SubaMuhurthamModel(
      id: id ?? this.id,
      tamilDate: tamilDate ?? this.tamilDate,
      englishDate: englishDate ?? this.englishDate,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      tithi: tithi ?? this.tithi,
      nakshatra: nakshatra ?? this.nakshatra,
      yoga: yoga ?? this.yoga,
      muhurthamTime: muhurthamTime ?? this.muhurthamTime,
      lagna: lagna ?? this.lagna,
      description: description ?? this.description,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Default records inspired by authentic Tamil Panchangam Subha Muhurtham chart
  static List<SubaMuhurthamModel> defaultList() {
    return [
      const SubaMuhurthamModel(
        id: 'sm_1',
        tamilDate: 'வைகாசி 02',
        englishDate: 'மே 16',
        dayOfWeek: 'வெள்ளி',
        tithi: 'சதுர்த்தி',
        nakshatra: 'மூலம்',
        yoga: 'அமிர்த யோகம்',
        muhurthamTime: 'காலை 9:10 - 9:22',
        lagna: 'மிதுனம் (தேய்பிறை)',
        description: 'திருமணம், சீமந்தம், உபநயனம், வாசல்கால் வைக்க, கிரக ஆரம்பம்',
        displayOrder: 1,
        isActive: true,
      ),
      const SubaMuhurthamModel(
        id: 'sm_2',
        tamilDate: 'வைகாசி 04',
        englishDate: 'மே 18',
        dayOfWeek: 'ஞாயிறு',
        tithi: 'சப்தமி',
        nakshatra: 'உத்திராடம்',
        yoga: 'அமிர்த யோகம்',
        muhurthamTime: 'காலை 10:28 - 10:42',
        lagna: 'மிதுனம் (தேய்பிறை)',
        description: 'புது வண்டி வாங்க, தொழில் தொடங்க, வியாபாரம், மாடுகன்றுகள் வாங்க',
        displayOrder: 2,
        isActive: true,
      ),
      const SubaMuhurthamModel(
        id: 'sm_3',
        tamilDate: 'வைகாசி 05',
        englishDate: 'மே 19',
        dayOfWeek: 'திங்கள்',
        tithi: 'அஷ்டமி',
        nakshatra: 'திருவோணம்',
        yoga: 'சித்த யோகம்',
        muhurthamTime: 'காலை 10:25 - 10:30',
        lagna: 'கன்னி',
        description: 'வியாபாரம் தொடங்க, கடன் வாங்க / அடைக்க',
        displayOrder: 3,
        isActive: true,
      ),
      const SubaMuhurthamModel(
        id: 'sm_4',
        tamilDate: 'வைகாசி 11',
        englishDate: 'மே 25',
        dayOfWeek: 'ஞாயிறு',
        tithi: 'துவிதியை',
        nakshatra: 'அசுவினி',
        yoga: 'சித்த யோகம்',
        muhurthamTime: 'காலை 6:11 - 6:24',
        lagna: 'மிதுனம் (வளர்பிறை)',
        description: 'திருமணம், சீமந்தம், உபநயனம், கிரக ஆரம்பம்',
        displayOrder: 4,
        isActive: true,
      ),
      const SubaMuhurthamModel(
        id: 'sm_5',
        tamilDate: 'வைகாசி 23',
        englishDate: 'ஜூன் 06',
        dayOfWeek: 'வெள்ளி',
        tithi: 'ஏகாதசி',
        nakshatra: 'சுவாதி',
        yoga: 'சித்த யோகம்',
        muhurthamTime: 'காலை 7:46 - 8:00',
        lagna: 'மிதுனம் (வளர்பிறை)',
        description: 'திருமணம், உபநயனம், புது வாகனம் ஏற, தொழில் ஆரம்பம்',
        displayOrder: 5,
        isActive: true,
      ),
      const SubaMuhurthamModel(
        id: 'sm_6',
        tamilDate: 'வைகாசி 25',
        englishDate: 'ஜூன் 08',
        dayOfWeek: 'ஞாயிறு',
        tithi: 'திரயோதசி',
        nakshatra: 'சித்திரை',
        yoga: 'சித்த யோகம்',
        muhurthamTime: 'காலை 8:08 - 8:21',
        lagna: 'மிதுனம் (வளர்பிறை)',
        description: 'திருமணம், சீமந்தம், வாசல்கால் வைக்க, புது வண்டி வாங்க',
        displayOrder: 6,
        isActive: true,
      ),
    ];
  }
}
