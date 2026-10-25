import 'dart:io';

/// Local persistent storage implementation for IO platforms (Mobile & Desktop)
class ProfileStorage {
  static const String _fileName = 'astrodashacare_profiles_v1.json';

  static File _getFile() {
    return File(_fileName);
  }

  static String? loadData() {
    try {
      final file = _getFile();
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        if (content.trim().isNotEmpty) return content;
      }
    } catch (_) {}

    try {
      final tempFile = File('${Directory.systemTemp.path}/$_fileName');
      if (tempFile.existsSync()) {
        final content = tempFile.readAsStringSync();
        if (content.trim().isNotEmpty) return content;
      }
    } catch (_) {}

    return null;
  }

  static void saveData(String data) {
    try {
      final file = _getFile();
      file.writeAsStringSync(data);
    } catch (_) {}

    try {
      final tempFile = File('${Directory.systemTemp.path}/$_fileName');
      tempFile.writeAsStringSync(data);
    } catch (_) {}
  }
}
