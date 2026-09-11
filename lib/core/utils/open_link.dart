import 'open_link_io.dart' if (dart.library.js_interop) 'open_link_web.dart' as impl;

/// Opens [url] in the system browser.
/// Uses `web.window.open` on web and `url_launcher` everywhere else so the
/// code compiles on every platform (package:web / dart:js_interop are
/// web-only libraries and must never leak into the Android/iOS build).
Future<void> openExternalLink(String url) => impl.openExternalLink(url);