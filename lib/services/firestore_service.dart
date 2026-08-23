import 'dart:async';
import '../models/terms_model.dart';
import '../models/astrologer_model.dart';
import '../models/magazine_model.dart';
import '../models/horoscope_model.dart';
import '../services/mock_data_service.dart';
import '../services/api_service.dart';

class FirestoreService {
  // Terms & Conditions (Admin editable, saved in MongoDB)
  static Future<List<TermItemModel>> fetchTermsAndConditions() async {
    final list = await ApiService.fetchTermsAndConditions();
    if (list.isNotEmpty) {
      MockDataService.termsAndConditions.clear();
      MockDataService.termsAndConditions.addAll(list);
      return list;
    }
    return List.from(MockDataService.termsAndConditions);
  }

  static Future<bool> addTerm(String title, String description) async {
    final newTerm = TermItemModel(
      id: 'tc_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      orderIndex: MockDataService.termsAndConditions.length + 1,
    );
    MockDataService.termsAndConditions.add(newTerm);
    await ApiService.addTerm(newTerm);
    return true;
  }

  static Future<bool> editTerm(String id, String title, String description) async {
    final index = MockDataService.termsAndConditions.indexWhere((t) => t.id == id);
    final updated = TermItemModel(
      id: id,
      title: title,
      description: description,
      orderIndex: index != -1 ? MockDataService.termsAndConditions[index].orderIndex : 1,
    );
    if (index != -1) {
      MockDataService.termsAndConditions[index] = updated;
    }
    await ApiService.editTerm(updated);
    return true;
  }

  static Future<bool> deleteTerm(String id) async {
    MockDataService.termsAndConditions.removeWhere((t) => t.id == id);
    await ApiService.deleteTerm(id);
    return true;
  }

  // Astrologers CRUD & Verification
  static Future<List<AstrologerModel>> fetchAstrologers() async {
    final list = await ApiService.fetchAstrologers();
    if (list.isNotEmpty) {
      MockDataService.astrologers.clear();
      MockDataService.astrologers.addAll(list);
      return list;
    }
    return List.from(MockDataService.astrologers);
  }

  static Future<bool> addAstrologer(AstrologerModel ast) async {
    MockDataService.astrologers.insert(0, ast);
    await ApiService.addAstrologer(ast);
    return true;
  }

  static Future<bool> editAstrologer(AstrologerModel updatedAst) async {
    final index = MockDataService.astrologers.indexWhere((a) => a.id == updatedAst.id);
    if (index != -1) {
      MockDataService.astrologers[index] = updatedAst;
    }
    await ApiService.editAstrologer(updatedAst);
    return true;
  }

  static Future<bool> deleteAstrologer(String id) async {
    MockDataService.astrologers.removeWhere((a) => a.id == id);
    await ApiService.deleteAstrologer(id);
    return true;
  }

  static Future<bool> approveAstrologer(String id) async {
    final index = MockDataService.astrologers.indexWhere((a) => a.id == id);
    if (index != -1) {
      final current = MockDataService.astrologers[index];
      MockDataService.astrologers[index] = AstrologerModel.fromMap({
        ...current.toMap(),
        'verificationStatus': 'approved',
      });
    }
    await ApiService.approveAstrologer(id);
    return true;
  }

  static Future<bool> rejectAstrologer(String id) async {
    final index = MockDataService.astrologers.indexWhere((a) => a.id == id);
    if (index != -1) {
      final current = MockDataService.astrologers[index];
      MockDataService.astrologers[index] = AstrologerModel.fromMap({
        ...current.toMap(),
        'verificationStatus': 'rejected',
      });
    }
    await ApiService.rejectAstrologer(id);
    return true;
  }

  // Magazine CMS
  static Future<List<MagazineArticleModel>> fetchMagazineArticles() async {
    final list = await ApiService.fetchMagazineArticles();
    if (list.isNotEmpty) {
      MockDataService.magazineArticles.clear();
      MockDataService.magazineArticles.addAll(list);
      return list;
    }
    return List.from(MockDataService.magazineArticles);
  }

  static Future<bool> addMagazineArticle(MagazineArticleModel article) async {
    MockDataService.magazineArticles.insert(0, article);
    await ApiService.addMagazineArticle(article);
    return true;
  }

  static Future<bool> editMagazineArticle(MagazineArticleModel article) async {
    final index = MockDataService.magazineArticles.indexWhere((a) => a.id == article.id);
    if (index != -1) {
      MockDataService.magazineArticles[index] = article;
    }
    await ApiService.editMagazineArticle(article);
    return true;
  }

  static Future<bool> deleteMagazineArticle(String id) async {
    MockDataService.magazineArticles.removeWhere((a) => a.id == id);
    await ApiService.deleteMagazineArticle(id);
    return true;
  }

  // Horoscope CRUD
  static Future<HoroscopePredictionModel> getHoroscopePrediction(String sign) async {
    final remote = await ApiService.getHoroscopePrediction(sign);
    if (remote != null) {
      MockDataService.customPredictions[sign] = remote;
      return remote;
    }
    if (MockDataService.customPredictions.containsKey(sign)) {
      return MockDataService.customPredictions[sign]!;
    }
    return HoroscopePredictionModel.forSign(sign);
  }

  static Future<bool> saveHoroscopePrediction(HoroscopePredictionModel prediction) async {
    MockDataService.customPredictions[prediction.zodiacSign] = prediction;
    MockDataService.deletedPredictions.remove(prediction.zodiacSign);
    await ApiService.saveHoroscopePrediction(prediction);
    return true;
  }

  static Future<bool> deleteHoroscopePrediction(String sign) async {
    MockDataService.customPredictions.remove(sign);
    MockDataService.deletedPredictions.add(sign);
    await ApiService.deleteHoroscopePrediction(sign);
    return true;
  }
}
