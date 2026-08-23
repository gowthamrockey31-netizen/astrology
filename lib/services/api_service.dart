import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/astrologer_model.dart';
import '../models/terms_model.dart';
import '../models/magazine_model.dart';
import '../models/horoscope_model.dart';
import '../models/wallet_transaction_model.dart';
import '../models/panchang_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // AUTH & USERS
  static Future<UserModel?> register(String phone, String password, {String name = 'Divine Seeker', String role = 'User'}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
          'name': name,
          'role': role,
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        if (data['user'] != null) {
          return UserModel.fromMap(Map<String, dynamic>.from(data['user']));
        }
      }
    } catch (e) {
      print('[ApiService] Register error: $e');
    }
    return null;
  }

  static Future<UserModel?> login(String phone, String password, {String role = 'User'}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
          'role': role,
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['user'] != null) {
          return UserModel.fromMap(Map<String, dynamic>.from(data['user']));
        }
      }
    } catch (e) {
      print('[ApiService] Login error: $e');
    }
    return null;
  }

  static Future<UserModel?> googleAuth(String email, String name, {String role = 'User'}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'name': name,
          'role': role,
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['user'] != null) {
          return UserModel.fromMap(Map<String, dynamic>.from(data['user']));
        }
      }
    } catch (e) {
      print('[ApiService] Google Auth error: $e');
    }
    return null;
  }

  static Future<bool> updateUserProfile(UserModel user) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toMap()),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('[ApiService] Update profile error: $e');
      return false;
    }
  }

  // ASTROLOGERS
  static Future<List<AstrologerModel>> fetchAstrologers() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/astrologers'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['astrologers'] ?? [];
        return list.map((item) => AstrologerModel.fromMap(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      print('[ApiService] fetchAstrologers error: $e');
    }
    return [];
  }

  static Future<bool> addAstrologer(AstrologerModel ast) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/astrologers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ast.toMap()),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print('[ApiService] addAstrologer error: $e');
      return false;
    }
  }

  static Future<bool> editAstrologer(AstrologerModel ast) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/astrologers/${ast.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ast.toMap()),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('[ApiService] editAstrologer error: $e');
      return false;
    }
  }

  static Future<bool> deleteAstrologer(String id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/astrologers/$id'));
      return res.statusCode == 200;
    } catch (e) {
      print('[ApiService] deleteAstrologer error: $e');
      return false;
    }
  }

  static Future<bool> approveAstrologer(String id) async {
    try {
      final res = await http.put(Uri.parse('$baseUrl/astrologers/$id/approve'));
      return res.statusCode == 200;
    } catch (e) {
      print('[ApiService] approveAstrologer error: $e');
      return false;
    }
  }

  static Future<bool> rejectAstrologer(String id) async {
    try {
      final res = await http.put(Uri.parse('$baseUrl/astrologers/$id/reject'));
      return res.statusCode == 200;
    } catch (e) {
      print('[ApiService] rejectAstrologer error: $e');
      return false;
    }
  }

  // TERMS & CONDITIONS
  static Future<List<TermItemModel>> fetchTermsAndConditions() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/terms'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['terms'] ?? [];
        return list.map((item) => TermItemModel.fromMap(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      print('[ApiService] fetchTerms error: $e');
    }
    return [];
  }

  static Future<bool> addTerm(TermItemModel term) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/terms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(term.toMap()),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print('[ApiService] addTerm error: $e');
      return false;
    }
  }

  static Future<bool> editTerm(TermItemModel term) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/terms/${term.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(term.toMap()),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('[ApiService] editTerm error: $e');
      return false;
    }
  }

  static Future<bool> deleteTerm(String id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/terms/$id'));
      return res.statusCode == 200;
    } catch (e) {
      print('[ApiService] deleteTerm error: $e');
      return false;
    }
  }

  // MAGAZINE ARTICLES
  static Future<List<MagazineArticleModel>> fetchMagazineArticles() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/magazine'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['articles'] ?? [];
        return list.map((item) => MagazineArticleModel.fromMap(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      print('[ApiService] fetchMagazineArticles error: $e');
    }
    return [];
  }

  static Future<bool> addMagazineArticle(MagazineArticleModel article) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/magazine'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(article.toMap()),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print('[ApiService] addMagazineArticle error: $e');
      return false;
    }
  }

  static Future<bool> editMagazineArticle(MagazineArticleModel article) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/magazine/${article.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(article.toMap()),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('[ApiService] editMagazineArticle error: $e');
      return false;
    }
  }

  static Future<bool> deleteMagazineArticle(String id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/magazine/$id'));
      return res.statusCode == 200;
    } catch (e) {
      print('[ApiService] deleteMagazineArticle error: $e');
      return false;
    }
  }

  // HOROSCOPE PREDICTIONS
  static Future<HoroscopePredictionModel?> getHoroscopePrediction(String sign) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/horoscope/$sign'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['prediction'] != null) {
          return HoroscopePredictionModel.fromMap(Map<String, dynamic>.from(data['prediction']));
        }
      }
    } catch (e) {
      print('[ApiService] getHoroscopePrediction error: $e');
    }
    return null;
  }

  static Future<bool> saveHoroscopePrediction(HoroscopePredictionModel prediction) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/horoscope'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(prediction.toMap()),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('[ApiService] saveHoroscopePrediction error: $e');
      return false;
    }
  }

  static Future<bool> deleteHoroscopePrediction(String sign) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/horoscope/$sign'));
      return res.statusCode == 200;
    } catch (e) {
      print('[ApiService] deleteHoroscopePrediction error: $e');
      return false;
    }
  }

  static Future<List<WalletTransactionModel>> fetchWalletTransactions(String? userId) async {
    try {
      final uri = userId != null && userId.isNotEmpty
          ? Uri.parse('$baseUrl/wallet/transactions?userId=$userId')
          : Uri.parse('$baseUrl/wallet/transactions');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['transactions'] ?? [];
        return list.map((item) => WalletTransactionModel.fromMap(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      // Api error handled gracefully
    }
    return [];
  }

  static final List<PanchangModel> _localPanchangList = [PanchangModel.today()];
  static final List<PlanetPositionModel> _localPlanetPositions = [
    PlanetPositionModel(id: 'plt_1', planet: 'Sun (Surya)', rasi: 'Cancer (Karka)', degrees: '12° 45\'', isRetrograde: false, nakshatra: 'Pushya'),
    PlanetPositionModel(id: 'plt_2', planet: 'Moon (Chandra)', rasi: 'Taurus (Vrishabha)', degrees: '24° 10\'', isRetrograde: false, nakshatra: 'Rohini'),
    PlanetPositionModel(id: 'plt_3', planet: 'Mars (Mangal)', rasi: 'Leo (Simha)', degrees: '08° 30\'', isRetrograde: false, nakshatra: 'Magha'),
    PlanetPositionModel(id: 'plt_4', planet: 'Mercury (Budha)', rasi: 'Gemini (Mithuna)', degrees: '18° 55\'', isRetrograde: true, nakshatra: 'Ardra'),
    PlanetPositionModel(id: 'plt_5', planet: 'Jupiter (Guru)', rasi: 'Taurus (Vrishabha)', degrees: '15° 20\'', isRetrograde: false, nakshatra: 'Rohini'),
    PlanetPositionModel(id: 'plt_6', planet: 'Venus (Shukra)', rasi: 'Cancer (Karka)', degrees: '05° 40\'', isRetrograde: false, nakshatra: 'Punarvasu'),
    PlanetPositionModel(id: 'plt_7', planet: 'Saturn (Shani)', rasi: 'Aquarius (Kumbha)', degrees: '21° 15\'', isRetrograde: true, nakshatra: 'Purva Bhadrapada'),
    PlanetPositionModel(id: 'plt_8', planet: 'Rahu (North Node)', rasi: 'Pisces (Meena)', degrees: '11° 02\'', isRetrograde: true, nakshatra: 'Uttara Bhadrapada'),
    PlanetPositionModel(id: 'plt_9', planet: 'Ketu (South Node)', rasi: 'Virgo (Kanya)', degrees: '11° 02\'', isRetrograde: true, nakshatra: 'Hasta'),
  ];

  // PANCHANG
  static Future<List<PanchangModel>> fetchPanchangEntries() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/panchang')).timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['panchang'] ?? [];
        if (list.isNotEmpty) {
          _localPanchangList.clear();
          _localPanchangList.addAll(list.map((item) => PanchangModel.fromMap(Map<String, dynamic>.from(item))));
        }
      }
    } catch (e) {
      print('[ApiService] fetchPanchang error: $e');
    }
    return List.from(_localPanchangList);
  }

  static Future<bool> addPanchangEntry(PanchangModel panchang) async {
    _localPanchangList.insert(0, panchang);
    try {
      await http.post(
        Uri.parse('$baseUrl/panchang'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(panchang.toMap()),
      );
    } catch (e) {
      print('[ApiService] addPanchang error: $e');
    }
    return true;
  }

  static Future<bool> editPanchangEntry(PanchangModel panchang) async {
    final idx = _localPanchangList.indexWhere((p) => p.id == panchang.id);
    if (idx != -1) {
      _localPanchangList[idx] = panchang;
    }
    try {
      await http.put(
        Uri.parse('$baseUrl/panchang/${panchang.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(panchang.toMap()),
      );
    } catch (e) {
      print('[ApiService] editPanchang error: $e');
    }
    return true;
  }

  static Future<bool> deletePanchangEntry(String id) async {
    _localPanchangList.removeWhere((p) => p.id == id);
    try {
      await http.delete(Uri.parse('$baseUrl/panchang/$id'));
    } catch (e) {
      print('[ApiService] deletePanchang error: $e');
    }
    return true;
  }

  // PLANET POSITIONS
  static Future<List<PlanetPositionModel>> fetchPlanetPositions() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/planets')).timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['planets'] ?? [];
        if (list.isNotEmpty) {
          _localPlanetPositions.clear();
          _localPlanetPositions.addAll(list.map((item) => PlanetPositionModel.fromMap(Map<String, dynamic>.from(item))));
        }
      }
    } catch (e) {
      print('[ApiService] fetchPlanetPositions error: $e');
    }
    return List.from(_localPlanetPositions);
  }

  static Future<bool> addPlanetPosition(PlanetPositionModel pos) async {
    _localPlanetPositions.insert(0, pos);
    try {
      await http.post(
        Uri.parse('$baseUrl/planets'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pos.toMap()),
      );
    } catch (e) {
      print('[ApiService] addPlanetPosition error: $e');
    }
    return true;
  }

  static Future<bool> editPlanetPosition(PlanetPositionModel pos) async {
    final idx = _localPlanetPositions.indexWhere((p) => p.id == pos.id);
    if (idx != -1) {
      _localPlanetPositions[idx] = pos;
    }
    try {
      await http.put(
        Uri.parse('$baseUrl/planets/${pos.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pos.toMap()),
      );
    } catch (e) {
      print('[ApiService] editPlanetPosition error: $e');
    }
    return true;
  }

  static Future<bool> deletePlanetPosition(String id) async {
    _localPlanetPositions.removeWhere((p) => p.id == id);
    try {
      await http.delete(Uri.parse('$baseUrl/planets/$id'));
    } catch (e) {
      print('[ApiService] deletePlanetPosition error: $e');
    }
    return true;
  }
}
