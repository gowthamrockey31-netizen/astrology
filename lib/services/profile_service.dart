import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'profile_storage.dart';

class ProfileOperationResult {
  final bool isSuccess;
  final String message;
  final UserModel? profile;

  const ProfileOperationResult({
    required this.isSuccess,
    required this.message,
    this.profile,
  });
}

/// Centralized service managing offline saved family profiles (Max 5 profiles),
/// persistent local storage, and profile switching across all astrology modules.
class ProfileService extends ChangeNotifier {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  /// Maximum allowed family profiles (Requirement 16)
  static const int maxProfiles = 5;

  static const String limitReachedMessageTa =
      'அதிகபட்ச வரம்பு: 5 குடும்ப ஜாதகங்கள் மட்டுமே சேமிக்க முடியும். புதிய ஜாதகம் சேர்க்க ஏதேனும் ஒன்றை நீக்கவும்.';
  static const String limitReachedMessageEn =
      'Maximum limit reached: Only up to 5 family profiles can be saved. Please delete an existing profile to add a new one.';

  List<UserModel> _profiles = [];
  String? _activeProfileId;
  bool _isInitialized = false;

  List<UserModel> get profiles => List.unmodifiable(_profiles);
  int get count => _profiles.length;
  bool get isFull => _profiles.length >= maxProfiles;
  bool get canAddProfile => _profiles.length < maxProfiles;
  String? get activeProfileId => _activeProfileId;
  bool get isInitialized => _isInitialized;

  /// The currently active/selected profile
  UserModel? get activeProfile {
    if (_profiles.isEmpty) return AuthService.currentUser;
    if (_activeProfileId != null) {
      try {
        return _profiles.firstWhere((p) => p.id == _activeProfileId);
      } catch (_) {}
    }
    return _profiles.first;
  }

  /// Initialize persistent storage and restore saved profiles offline
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final rawData = ProfileStorage.loadData();
      if (rawData != null && rawData.trim().isNotEmpty) {
        final decoded = json.decode(rawData);
        if (decoded is Map<String, dynamic>) {
          if (decoded['profiles'] is List) {
            _profiles = (decoded['profiles'] as List)
                .map((item) => UserModel.fromMap(Map<String, dynamic>.from(item)))
                .take(maxProfiles)
                .toList();
          }
          if (decoded['activeProfileId'] != null) {
            _activeProfileId = decoded['activeProfileId'].toString();
          }
        } else if (decoded is List) {
          _profiles = decoded
              .map((item) => UserModel.fromMap(Map<String, dynamic>.from(item)))
              .take(maxProfiles)
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[ProfileService] Error loading profiles: $e');
    }

    // If storage is empty, initialize with current user or a default profile
    if (_profiles.isEmpty) {
      final existingUser = AuthService.currentUser;
      final defaultProfile = existingUser != null
          ? existingUser.copyWith(
              id: existingUser.id.isNotEmpty ? existingUser.id : 'prof_self',
              relationship: existingUser.relationship.isNotEmpty ? existingUser.relationship : 'Self',
            )
          : UserModel(
              id: 'prof_self',
              name: 'முதன்மை ஜாதகர் (Self)',
              mobile: '+91 9876543210',
              gender: 'Male',
              dob: '1995-08-15',
              timeOfBirth: '08:30 AM',
              placeOfBirth: 'Chennai, Tamil Nadu',
              city: 'Chennai',
              state: 'Tamil Nadu',
              country: 'India',
              zodiac: 'Leo',
              nakshatra: 'Purva Phalguni',
              lagna: 'Leo',
              walletBalance: 1000.0,
              role: 'User',
              profilePhoto: '',
              latitude: 13.0827,
              longitude: 80.2707,
              timezone: 5.5,
              relationship: 'Self',
            );

      _profiles.add(defaultProfile);
      _activeProfileId = defaultProfile.id;
      _persist();
    }

    // Ensure valid active profile
    if (_activeProfileId == null || !_profiles.any((p) => p.id == _activeProfileId)) {
      _activeProfileId = _profiles.first.id;
    }

    // Sync active profile to AuthService so existing modules receive it seamlessly
    final current = activeProfile;
    if (current != null) {
      AuthService.updateCurrentUser(current);
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Select and switch to a profile (Requirement 17)
  Future<void> selectProfile(String profileId) async {
    if (_activeProfileId == profileId) return;

    final targetIndex = _profiles.indexWhere((p) => p.id == profileId);
    if (targetIndex != -1) {
      _activeProfileId = profileId;
      final selected = _profiles[targetIndex];

      // Update AuthService and existing calculation state
      AuthService.updateCurrentUser(selected);

      _persist();
      notifyListeners();
    }
  }

  /// Alias for selectProfile
  Future<void> setActiveProfile(String profileId) => selectProfile(profileId);

  /// Add a new family profile with hard limit enforcement (Requirement 16)
  Future<ProfileOperationResult> addProfile(UserModel newProfile) async {
    if (_profiles.length >= maxProfiles) {
      return const ProfileOperationResult(
        isSuccess: false,
        message: limitReachedMessageTa,
      );
    }

    final String generatedId = newProfile.id.isNotEmpty
        ? newProfile.id
        : 'prof_${DateTime.now().millisecondsSinceEpoch}_${_profiles.length + 1}';

    final profileToAdd = newProfile.copyWith(id: generatedId);
    _profiles.add(profileToAdd);

    // Switch to newly created profile
    _activeProfileId = profileToAdd.id;
    AuthService.updateCurrentUser(profileToAdd);

    _persist();
    notifyListeners();

    return ProfileOperationResult(
      isSuccess: true,
      message: 'குடும்ப ஜாதகம் வெற்றிகரமாகச் சேமிக்கப்பட்டது.',
      profile: profileToAdd,
    );
  }

  /// Update an existing profile
  Future<ProfileOperationResult> updateProfile(UserModel updatedProfile) async {
    final index = _profiles.indexWhere((p) => p.id == updatedProfile.id);
    if (index == -1) {
      return const ProfileOperationResult(
        isSuccess: false,
        message: 'ஜாதகம் கண்டறியப்படவில்லை.',
      );
    }

    _profiles[index] = updatedProfile;

    if (_activeProfileId == updatedProfile.id) {
      AuthService.updateCurrentUser(updatedProfile);
    }

    _persist();
    notifyListeners();

    return ProfileOperationResult(
      isSuccess: true,
      message: 'ஜாதக விபரங்கள் புதுப்பிக்கப்பட்டன.',
      profile: updatedProfile,
    );
  }

  /// Delete a saved profile
  Future<bool> deleteProfile(String profileId) async {
    final index = _profiles.indexWhere((p) => p.id == profileId);
    if (index == -1) return false;

    _profiles.removeAt(index);

    if (_activeProfileId == profileId) {
      if (_profiles.isNotEmpty) {
        _activeProfileId = _profiles.first.id;
        AuthService.updateCurrentUser(_profiles.first);
      } else {
        _activeProfileId = null;
      }
    }

    _persist();
    notifyListeners();
    return true;
  }

  /// Save profiles persistently to offline storage (Requirement 18)
  void _persist() {
    try {
      final payload = {
        'version': 1,
        'activeProfileId': _activeProfileId,
        'profiles': _profiles.map((p) => p.toMap()).toList(),
      };
      ProfileStorage.saveData(json.encode(payload));
    } catch (e) {
      debugPrint('[ProfileService] Error persisting profiles: $e');
    }
  }

  /// For unit testing only: reset internal state and reload
  @visibleForTesting
  void resetForTesting() {
    _profiles = [];
    _activeProfileId = null;
    _isInitialized = false;
  }
}
