// ---------------------------------------------------------------------------
// AMAZON ASSOCIATES — central constants for the Flutter web client.
//
// SECURITY & TYPING NOTES
// * The backend is the source of truth for affiliate URLs and the tracking
//   ID. The Flutter client receives prebuilt URLs from the backend and only
//   needs a single fallback constant for offline/error resilience.
// * The tracking ID (clickshop03b-20) is public — it appears in affiliate
//   URLs — so it is NOT a secret. Nothing else here is a secret.
// * No API credentials ever appear in Flutter code, assets, or this bundle.
// ---------------------------------------------------------------------------

/// Fallback destination used only when the backend cannot be reached, so the
/// Amazon section is never left as a forever-spinner.
const String kAmazonAffiliateFallbackUrl =
    'https://www.amazon.com/s?k=gaming&tag=clickshop03b-20';

/// Local asset image for a curated category, keyed by the backend's
/// `imageKey` value. Categories without a local asset fall back to an icon.
/// These are Click Shop's own assets — never scraped Amazon images.
const Map<String, String> kAmazonCategoryAssets = {
  'gaming': 'assets/images/game_pc1.jpg',
  'gaming_pc': 'assets/images/game_pc1.jpg',
  'laptop': 'assets/images/omen1.jpg',
  'keyboard': 'assets/images/keyboard1.jpg',
  'mouse': 'assets/images/mouse_1.jpg',
  'headset': 'assets/images/head_set.jpg',
};