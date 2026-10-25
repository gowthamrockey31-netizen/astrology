// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Local persistent storage implementation for Web platform using localStorage
class ProfileStorage {
  static const String _key = 'astrodashacare_saved_profiles_v1';

  static String? loadData() {
    try {
      return html.window.localStorage[_key];
    } catch (_) {
      return null;
    }
  }

  static void saveData(String data) {
    try {
      html.window.localStorage[_key] = data;
    } catch (_) {}
  }
}
