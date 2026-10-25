class UserModel {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String gender;
  final String dob;
  final String timeOfBirth;
  final String placeOfBirth;
  final String city;
  final String state;
  final String country;
  final String zodiac;
  final String nakshatra;
  final String lagna;
  final double walletBalance;
  final String role; // User, Astrologer, Admin
  final String profilePhoto;
  final List<String> pinnedAstrologers;

  final double latitude;
  final double longitude;
  final double timezone;
  final String relationship; // Self, Father, Mother, Spouse, Child, Brother, Sister, Other

  UserModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    required this.gender,
    required this.dob,
    required this.timeOfBirth,
    required this.placeOfBirth,
    required this.city,
    required this.state,
    required this.country,
    required this.zodiac,
    required this.nakshatra,
    required this.lagna,
    required this.walletBalance,
    this.role = 'User',
    required this.profilePhoto,
    this.pinnedAstrologers = const [],
    this.latitude = 13.0827,
    this.longitude = 80.2707,
    this.timezone = 5.5,
    this.relationship = 'Self',
  });

  /// Check if user has Admin privileges
  bool get isAdmin => role.toLowerCase() == 'admin';

  /// Convenient alias for timeOfBirth
  String get tob => timeOfBirth;

  /// Automatically calculate age from DOB
  int get calculatedAge {
    try {
      final parsed = DateTime.tryParse(dob);
      if (parsed == null) return 28;
      final now = DateTime.now();
      int age = now.year - parsed.year;
      if (now.month < parsed.month || (now.month == parsed.month && now.day < parsed.day)) {
        age--;
      }
      return age < 0 ? 0 : age;
    } catch (_) {
      return 28;
    }
  }

  /// Exact DateTime of birth combining dob and timeOfBirth
  DateTime get birthDateTime {
    try {
      final dateParts = dob.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      int hour = 12;
      int min = 0;
      final t = timeOfBirth.trim().toUpperCase();
      if (t.contains(':')) {
        final isPm = t.contains('PM');
        final isAm = t.contains('AM');
        final cleanT = t.replaceAll('AM', '').replaceAll('PM', '').trim();
        final tp = cleanT.split(':');
        hour = int.tryParse(tp[0]) ?? 12;
        min = int.tryParse(tp.length > 1 ? tp[1] : '0') ?? 0;
        if (isPm && hour < 12) hour += 12;
        if (isAm && hour == 12) hour = 0;
      }
      return DateTime(year, month, day, hour, min);
    } catch (_) {
      return DateTime(2000, 1, 1, 12, 0);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'gender': gender,
      'dob': dob,
      'timeOfBirth': timeOfBirth,
      'placeOfBirth': placeOfBirth,
      'city': city,
      'state': state,
      'country': country,
      'zodiac': zodiac,
      'nakshatra': nakshatra,
      'lagna': lagna,
      'walletBalance': walletBalance,
      'role': role,
      'profilePhoto': profilePhoto,
      'pinnedAstrologers': pinnedAstrologers,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'relationship': relationship,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Divine Seeker',
      mobile: map['mobile'] ?? '',
      email: map['email'],
      gender: map['gender'] ?? 'Male',
      dob: map['dob'] ?? '2000-01-01',
      timeOfBirth: map['timeOfBirth'] ?? '08:30 AM',
      placeOfBirth: map['placeOfBirth'] ?? 'Chennai',
      city: map['city'] ?? 'Chennai',
      state: map['state'] ?? 'Tamil Nadu',
      country: map['country'] ?? 'India',
      zodiac: map['zodiac'] ?? 'Aries (Mesha)',
      nakshatra: map['nakshatra'] ?? 'Ashwini',
      lagna: map['lagna'] ?? 'Mesha',
      walletBalance: (map['walletBalance'] as num?)?.toDouble() ?? 500.0,
      role: map['role'] ?? 'User',
      profilePhoto: map['profilePhoto'] ?? '',
      pinnedAstrologers: List<String>.from(map['pinnedAstrologers'] ?? []),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 13.0827,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 80.2707,
      timezone: (map['timezone'] as num?)?.toDouble() ?? 5.5,
      relationship: map['relationship'] ?? 'Self',
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? gender,
    String? dob,
    String? timeOfBirth,
    String? placeOfBirth,
    String? city,
    String? state,
    String? country,
    String? zodiac,
    String? nakshatra,
    String? lagna,
    double? walletBalance,
    String? role,
    String? profilePhoto,
    List<String>? pinnedAstrologers,
    double? latitude,
    double? longitude,
    double? timezone,
    String? relationship,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      timeOfBirth: timeOfBirth ?? this.timeOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      zodiac: zodiac ?? this.zodiac,
      nakshatra: nakshatra ?? this.nakshatra,
      lagna: lagna ?? this.lagna,
      walletBalance: walletBalance ?? this.walletBalance,
      role: role ?? this.role,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      pinnedAstrologers: pinnedAstrologers ?? this.pinnedAstrologers,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
      relationship: relationship ?? this.relationship,
    );
  }
}
