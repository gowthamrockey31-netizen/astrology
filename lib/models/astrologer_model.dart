typedef Astrologer = AstrologerModel;

class AstrologerModel {
  final String id;
  final String name;
  final String photoUrl;
  final String mobile;
  final String email;
  final String password;
  final String gender;
  final String city;
  final String state;
  final int experienceYears;
  final String qualification;
  final List<String> specializations;
  final List<String> languages;
  final double consultationFee; // rate per minute or session
  final double rating;
  final int totalReviews;
  final String status; // online, busy, offline
  final String? breakTimer; // 15m, 30m
  final int estimatedWaitMinutes;
  final String verificationStatus; // pending, approved, rejected
  final String panCard;
  final String aadhaarNumber;
  final String bankAccount;
  final String upiId;
  final String employmentType; // Full-Time, Part-Time
  final double todayEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final double totalEarnings;
  final double walletBalance;
  final double pendingPayout;
  final double completedPayout;

  AstrologerModel({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.mobile,
    required this.email,
    this.password = 'password123',
    required this.gender,
    required this.city,
    required this.state,
    required this.experienceYears,
    required this.qualification,
    required this.specializations,
    required this.languages,
    required this.consultationFee,
    required this.rating,
    required this.totalReviews,
    required this.status,
    this.breakTimer,
    required this.estimatedWaitMinutes,
    required this.verificationStatus,
    this.panCard = 'N/A',
    this.aadhaarNumber = 'N/A',
    this.bankAccount = 'N/A',
    this.upiId = 'N/A',
    this.employmentType = 'Full-Time',
    this.todayEarnings = 0.0,
    this.weeklyEarnings = 0.0,
    this.monthlyEarnings = 0.0,
    this.totalEarnings = 0.0,
    this.walletBalance = 0.0,
    this.pendingPayout = 0.0,
    this.completedPayout = 0.0,
  });

  // Legacy getters
  String get title => qualification;
  String get experience => '$experienceYears+ Yrs';
  int get reviewsCount => totalReviews;
  String get imageUrl => photoUrl;
  bool get isOnline => status == 'online';
  double get pricePerMin => consultationFee;

  // Calculate 20% platform commission
  double get platformCommission => totalEarnings * 0.20;
  double get netEarnings => totalEarnings * 0.80;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'mobile': mobile,
      'email': email,
      'password': password,
      'gender': gender,
      'city': city,
      'state': state,
      'experienceYears': experienceYears,
      'qualification': qualification,
      'specializations': specializations,
      'languages': languages,
      'consultationFee': consultationFee,
      'rating': rating,
      'totalReviews': totalReviews,
      'status': status,
      'breakTimer': breakTimer,
      'estimatedWaitMinutes': estimatedWaitMinutes,
      'verificationStatus': verificationStatus,
      'panCard': panCard,
      'aadhaarNumber': aadhaarNumber,
      'bankAccount': bankAccount,
      'upiId': upiId,
      'employmentType': employmentType,
      'todayEarnings': todayEarnings,
      'weeklyEarnings': weeklyEarnings,
      'monthlyEarnings': monthlyEarnings,
      'totalEarnings': totalEarnings,
      'walletBalance': walletBalance,
      'pendingPayout': pendingPayout,
      'completedPayout': completedPayout,
    };
  }

  factory AstrologerModel.fromMap(Map<String, dynamic> map) {
    return AstrologerModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'] ?? map['imageUrl'] ?? '',
      mobile: map['mobile'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? 'password123',
      gender: map['gender'] ?? 'Male',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      experienceYears: map['experienceYears'] ?? 5,
      qualification: map['qualification'] ?? map['title'] ?? 'Acharya in Vedic Astrology',
      specializations: List<String>.from(map['specializations'] ?? ['Vedic Astrology']),
      languages: List<String>.from(map['languages'] ?? ['English', 'Tamil']),
      consultationFee: (map['consultationFee'] as num?)?.toDouble() ?? (map['pricePerMin'] as num?)?.toDouble() ?? 25.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.9,
      totalReviews: map['totalReviews'] ?? map['reviewsCount'] ?? 120,
      status: map['status'] ?? ((map['isOnline'] == true) ? 'online' : 'offline'),
      breakTimer: map['breakTimer'],
      estimatedWaitMinutes: map['estimatedWaitMinutes'] ?? 0,
      verificationStatus: map['verificationStatus'] ?? 'approved',
      panCard: map['panCard'] ?? '',
      aadhaarNumber: map['aadhaarNumber'] ?? '',
      bankAccount: map['bankAccount'] ?? '',
      upiId: map['upiId'] ?? '',
      employmentType: map['employmentType'] ?? 'Full-Time',
      todayEarnings: (map['todayEarnings'] as num?)?.toDouble() ?? 1250.0,
      weeklyEarnings: (map['weeklyEarnings'] as num?)?.toDouble() ?? 8400.0,
      monthlyEarnings: (map['monthlyEarnings'] as num?)?.toDouble() ?? 34500.0,
      totalEarnings: (map['totalEarnings'] as num?)?.toDouble() ?? 128000.0,
      walletBalance: (map['walletBalance'] as num?)?.toDouble() ?? 102400.0,
      pendingPayout: (map['pendingPayout'] as num?)?.toDouble() ?? 15000.0,
      completedPayout: (map['completedPayout'] as num?)?.toDouble() ?? 87400.0,
    );
  }
}
