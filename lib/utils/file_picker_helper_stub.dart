/// Mobile/Desktop stub: image picking via dart:html is not supported.
/// On Android/iOS, use image_picker package instead.
/// Here we simply notify the caller that it is unsupported on this platform.
void pickImageFile(Function(String photoDataUrl) onPicked) {
  // No-op on non-web platforms.
  // The caller already guards with kIsWeb, so this should never be reached.
}
