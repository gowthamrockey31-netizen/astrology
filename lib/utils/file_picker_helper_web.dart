import 'dart:html' as html;

/// Web implementation: uses dart:html FileUploadInputElement.
void pickImageFile(Function(String photoDataUrl) onPicked) {
  final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
  uploadInput.click();
  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final reader = html.FileReader();
      reader.readAsDataUrl(files[0]);
      reader.onLoadEnd.listen((e) {
        if (reader.result != null) {
          onPicked(reader.result as String);
        }
      });
    }
  });
}
