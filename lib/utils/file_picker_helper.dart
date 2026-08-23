// Cross-platform file picker helper.
// Uses dart:html on web, stub on mobile.
export 'file_picker_helper_stub.dart'
    if (dart.library.html) 'file_picker_helper_web.dart';
