// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class SubaMuhurthamStorage {
  static const String _key = 'suba_muhurtham_data_v1';

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
