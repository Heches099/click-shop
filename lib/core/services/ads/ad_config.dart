/// Google AdSense configuration for the web build.
///
/// To go live:
/// 1. Create an AdSense account and a site for your deployed domain.
/// 2. Replace `publisherClientId` with your real client id (ca-pub-...).
/// 3. Create ad units and copy each unit's slot id into the fields below.
/// 4. Set `enabled` to `true`.
///
/// Ad slots only render on Flutter web builds — mobile/desktop are untouched.
class AdConfig {
  /// MASTER CONFIGURATION
  /// 1. Create AdSense account -> Get Publisher ID (ca-pub-XXX).
  /// 2. Create AdMob account -> Get App IDs & Unit IDs.
  /// 3. Replace values below.
  /// 4. Add ads.txt to your web domain root.

  /// Placeholder — replace with your real AdSense publisher client id.
  static const String publisherClientId = 'ca-pub-0000000000000000';

  /// AdMob App IDs (Required for Android/iOS)
  /// Replace these in android/app/src/main/AndroidManifest.xml 
  /// and ios/Runner/Info.plist respectively.
  static const String androidAppId = 'ca-app-pub-0000000000000000~0000000000';
  static const String iosAppId = 'ca-app-pub-0000000000000000~0000000000';

  /// AdMob unit IDs for mobile. Using test IDs by default.
  /// Replace with your production unit IDs before releasing to stores.
  static const String androidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String iosBannerId = 'ca-app-pub-3940256099942544/2934735716';

  /// Placeholder ad unit slot ids (from your AdSense "Ad units" page).
  static const String homeTopSlot = '0000000000';
  static const String productSlot = '0000000000';

  /// Master switch. Set to true to enable ads.
  static const bool enabled = true;

  static bool get isConfigured => enabled;
}
