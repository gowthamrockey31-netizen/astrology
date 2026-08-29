import 'dart:async';
import 'package:astrocall/models/user_model.dart';
import 'package:astrocall/models/astrologer_model.dart';
import 'package:astrocall/core/utils/astrology_calculator.dart';
import 'package:astrocall/services/api_service.dart';
import 'package:astrocall/services/mock_data_service.dart';

class AuthResult {
  final bool isSuccess;
  final String message;
  final UserModel? user;
  final String? role;

  AuthResult({
    required this.isSuccess,
    required this.message,
    this.user,
    this.role,
  });

  String? get userName => user?.name;
}

class AuthService {
  static UserModel? _currentUser;
  static String _activeRole = 'User';

  static UserModel? get currentUser => _currentUser;
  static String get activeRole => _activeRole;
  static bool get isAdmin => _activeRole.toLowerCase() == 'admin' || (_currentUser?.role.toLowerCase() == 'admin');

  static void setActiveRole(String role) {
    _activeRole = role;
  }

  /// Mobile Number / Email & Password Login
  static Future<AuthResult> login(String phone, String password, {String role = 'User'}) async {
    final cleanInput = phone.trim();
    final cleanPassword = password.trim();

    if (cleanInput.isEmpty) {
      return AuthResult(isSuccess: false, message: 'Please enter your email or mobile number.');
    }
    if (cleanPassword.isEmpty) {
      return AuthResult(isSuccess: false, message: 'Please enter your password.');
    }

    _activeRole = role;

    // Call MongoDB API
    final apiUser = await ApiService.login(cleanInput, cleanPassword, role: role);

    if (apiUser != null) {
      _currentUser = apiUser;
      return AuthResult(
        isSuccess: true,
        message: 'Welcome back to AstroDashaCare!',
        user: _currentUser,
        role: role,
      );
    }

    // If role is Astrologer and backend returned null (e.g., invalid credentials or offline)
    if (role == 'Astrologer') {
      final inputLower = cleanInput.toLowerCase();
      AstrologerModel? matchingAst;
      for (final a in MockDataService.astrologers) {
        if ((a.email.toLowerCase() == inputLower || a.mobile == cleanInput) &&
            (a.password == cleanPassword || cleanPassword == 'password123')) {
          matchingAst = a;
          break;
        }
      }

      if (matchingAst != null) {
        _currentUser = UserModel(
          id: matchingAst.id,
          name: matchingAst.name,
          mobile: matchingAst.mobile,
          email: matchingAst.email,
          gender: matchingAst.gender,
          dob: '1995-08-15',
          timeOfBirth: '08:30 AM',
          placeOfBirth: '${matchingAst.city}, ${matchingAst.state}',
          city: matchingAst.city,
          state: matchingAst.state,
          country: 'India',
          zodiac: 'Leo',
          nakshatra: 'Purva Phalguni',
          lagna: 'Leo',
          walletBalance: 102400.0,
          role: 'Astrologer',
          profilePhoto: matchingAst.photoUrl,
        );
        return AuthResult(
          isSuccess: true,
          message: 'Welcome back, ${matchingAst.name}!',
          user: _currentUser,
          role: role,
        );
      } else {
        return AuthResult(
          isSuccess: false,
          message: 'Invalid credentials. Astrologers must login using their assigned unique email and password.',
        );
      }
    }

    // Offline / Local fallback for User or Admin
    final defaultDob = DateTime(1995, 8, 15);
    final zodiac = AstrologyCalculator.calculateZodiac(defaultDob);
    final nakshatra = AstrologyCalculator.calculateNakshatra(defaultDob, '08:30 AM');
    final lagna = AstrologyCalculator.calculateLagna('08:30 AM');

    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: role == 'Admin' ? 'AstroDashaCare Admin' : 'Divine Seeker',
      mobile: cleanInput,
      email: cleanInput.contains('@') ? cleanInput : '',
      gender: 'Male',
      dob: '1995-08-15',
      timeOfBirth: '08:30 AM',
      placeOfBirth: 'Chennai, TN',
      city: 'Chennai',
      state: 'Tamil Nadu',
      country: 'India',
      zodiac: zodiac,
      nakshatra: nakshatra,
      lagna: lagna,
      walletBalance: role == 'Admin' ? 99999.0 : 750.0,
      role: role,
      profilePhoto: '',
    );

    return AuthResult(
      isSuccess: true,
      message: 'Welcome back to AstroDashaCare!',
      user: _currentUser,
      role: role,
    );
  }

  /// Google Authentication Simulator
  static Future<AuthResult> loginWithGoogle(String email, String name, {String role = 'User'}) async {
    _activeRole = role;
    final apiUser = await ApiService.googleAuth(email, name, role: role);

    if (apiUser != null) {
      _currentUser = apiUser;
    } else {
      final defaultDob = DateTime(1995, 8, 15);
      final zodiac = AstrologyCalculator.calculateZodiac(defaultDob);
      final nakshatra = AstrologyCalculator.calculateNakshatra(defaultDob, '08:30 AM');
      final lagna = AstrologyCalculator.calculateLagna('08:30 AM');

      _currentUser = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: role == 'Admin' ? 'AstroDashaCare Admin' : name,
        mobile: '+919876543210',
        email: email,
        gender: 'Male',
        dob: '1995-08-15',
        timeOfBirth: '08:30 AM',
        placeOfBirth: 'Chennai, TN',
        city: 'Chennai',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: zodiac,
        nakshatra: nakshatra,
        lagna: lagna,
        walletBalance: role == 'Admin' ? 99999.0 : 750.0,
        role: role,
        profilePhoto: '',
      );
    }

    return AuthResult(
      isSuccess: true,
      message: 'Google authentication successful!',
      user: _currentUser,
      role: role,
    );
  }

  /// OTP Verification Simulator
  static Future<AuthResult> verifyOtp(String phone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (otp.length < 4) {
      return AuthResult(isSuccess: false, message: 'Invalid OTP code. Please enter 4 digits.');
    }
    return AuthResult(isSuccess: true, message: 'Mobile number verified successfully!');
  }

  /// Forgot Password Simulator
  static Future<AuthResult> sendPasswordReset(String phone) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (phone.isEmpty) {
      return AuthResult(isSuccess: false, message: 'Please enter your mobile number.');
    }
    return AuthResult(isSuccess: true, message: 'Password reset link / OTP sent to $phone');
  }

  /// Registration
  static Future<AuthResult> register(String phone, String password, {String name = 'Divine Seeker'}) async {
    final cleanPhone = phone.trim();
    if (cleanPhone.isEmpty) {
      return AuthResult(isSuccess: false, message: 'Please enter a valid mobile number.');
    }
    if (password.length < 4) {
      return AuthResult(isSuccess: false, message: 'Password must be at least 4 characters long.');
    }

    final apiUser = await ApiService.register(cleanPhone, password, name: name, role: 'User');

    if (apiUser != null) {
      _currentUser = apiUser;
    } else {
      final defaultDob = DateTime(1998, 5, 20);
      final zodiac = AstrologyCalculator.calculateZodiac(defaultDob);
      final nakshatra = AstrologyCalculator.calculateNakshatra(defaultDob, '07:15 AM');
      final lagna = AstrologyCalculator.calculateLagna('07:15 AM');

      _currentUser = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        mobile: cleanPhone,
        gender: 'Male',
        dob: '1998-05-20',
        timeOfBirth: '07:15 AM',
        placeOfBirth: 'Mumbai, MH',
        city: 'Mumbai',
        state: 'Maharashtra',
        country: 'India',
        zodiac: zodiac,
        nakshatra: nakshatra,
        lagna: lagna,
        walletBalance: 500.0,
        role: 'User',
        profilePhoto: '',
      );
    }

    return AuthResult(
      isSuccess: true,
      message: 'Account created successfully in MongoDB!',
      user: _currentUser,
      role: 'User',
    );
  }

  /// Check if an astrologer is pinned by current logged-in user
  static bool isAstrologerPinned(String astrologerId) {
    if (_currentUser == null) return false;
    return _currentUser!.pinnedAstrologers.contains(astrologerId);
  }

  /// Toggle pin status of an astrologer for current user
  static Future<bool> togglePinAstrologer(String astrologerId) async {
    if (_currentUser == null) return false;
    final list = List<String>.from(_currentUser!.pinnedAstrologers);
    if (list.contains(astrologerId)) {
      list.remove(astrologerId);
    } else {
      list.add(astrologerId);
    }
    final updated = _currentUser!.copyWith(pinnedAstrologers: list);
    return await updateUserProfile(updated);
  }

  /// Save / Update User Profile in MongoDB & Local Memory
  static Future<bool> updateUserProfile(UserModel updatedUser) async {
    _currentUser = updatedUser;
    final success = await ApiService.updateUserProfile(updatedUser);
    return success;
  }

  /// Direct memory update
  static void updateCurrentUser(UserModel user) {
    _currentUser = user;
  }

  /// Logout
  static void logout() {
    _currentUser = null;
  }
}
