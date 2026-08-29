// Platform bridge for Google AdSense.
//
// On web builds the `adsense_loader_web.dart` implementation is used; on all
// other platforms the stub keeps every call a no-op so the app builds fine.
import 'adsense_loader_stub.dart'
    if (dart.library.js_interop) 'adsense_loader_web.dart' as impl;

/// Whether AdSense can run on this platform (web only).
bool get adsenseAvailable => impl.adsenseAvailable;

/// Registers an ad slot as a Flutter platform view and returns its view type.
String registerAdSlot() => impl.registerAdSlot();

/// Injects the AdSense script once. Safe to call repeatedly.
///
/// The script is only injected after the app's first visual frame
/// (`flutter-first-frame`), so advertising code never delays or shifts the
/// initial render. Returns a future that completes once injection happened.
Future<void> loadAdSense() => impl.loadAdSense();

/// Renders an ad unit into the DOM element registered under [viewType].
void renderAdSlot(String viewType, String slotId) =>
    impl.renderAdSlot(viewType, slotId);
