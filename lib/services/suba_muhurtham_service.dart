import 'dart:convert';
import '../models/suba_muhurtham_model.dart';
import 'suba_muhurtham_storage.dart';

class SubaMuhurthamService {
  static List<SubaMuhurthamModel>? _cache;

  /// Loads all Suba Muhurtham records persistently.
  static Future<List<SubaMuhurthamModel>> fetchList({bool includeInactive = false}) async {
    _cache ??= _loadFromStorage();

    final list = List<SubaMuhurthamModel>.from(_cache!);
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    if (!includeInactive) {
      return list.where((item) => item.isActive).toList();
    }
    return list;
  }

  static List<SubaMuhurthamModel> _loadFromStorage() {
    try {
      final jsonStr = SubaMuhurthamStorage.loadData();
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List && decoded.isNotEmpty) {
          return decoded
              .map((item) => SubaMuhurthamModel.fromMap(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (_) {}

    // Default seed data
    final defaults = SubaMuhurthamModel.defaultList();
    _saveToStorage(defaults);
    return defaults;
  }

  static void _saveToStorage(List<SubaMuhurthamModel> list) {
    try {
      final jsonStr = jsonEncode(list.map((e) => e.toMap()).toList());
      SubaMuhurthamStorage.saveData(jsonStr);
    } catch (_) {}
  }

  /// Adds a new Suba Muhurtham entry
  static Future<bool> add(SubaMuhurthamModel item) async {
    _cache ??= _loadFromStorage();
    _cache!.add(item);
    _saveToStorage(_cache!);
    return true;
  }

  /// Updates an existing Suba Muhurtham entry
  static Future<bool> edit(SubaMuhurthamModel item) async {
    _cache ??= _loadFromStorage();
    final idx = _cache!.indexWhere((e) => e.id == item.id);
    if (idx != -1) {
      _cache![idx] = item;
      _saveToStorage(_cache!);
      return true;
    }
    return false;
  }

  /// Deletes a Suba Muhurtham entry by ID
  static Future<bool> delete(String id) async {
    _cache ??= _loadFromStorage();
    _cache!.removeWhere((e) => e.id == id);
    _saveToStorage(_cache!);
    return true;
  }

  /// Reorders items
  static Future<bool> reorder(int oldIndex, int newIndex) async {
    _cache ??= _loadFromStorage();
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _cache!.removeAt(oldIndex);
    _cache!.insert(newIndex, item);

    // Update displayOrder
    for (int i = 0; i < _cache!.length; i++) {
      _cache![i] = _cache![i].copyWith(displayOrder: i + 1);
    }
    _saveToStorage(_cache!);
    return true;
  }

  /// Reset to default Panchangam entries
  static Future<void> resetToDefaults() async {
    _cache = SubaMuhurthamModel.defaultList();
    _saveToStorage(_cache!);
  }
}
