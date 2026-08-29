// ClickShop — custom Flutter web bootstrap.
//
// The `{{flutter_js}}` and `{{flutter_build_config}}` tokens are replaced by
// the Flutter build with the loader source and build metadata.
//
// Hardening rules on top of the default bootstrap:
//   1. Known search-engine crawlers that reach origin directly never start the
//      heavy engine — they receive the static <noscript>/prerendered markup.
//   2. The native WebAssembly renderer (skwasm) is preferred when a wasm build
//      is served, with a transparent fallback to the standard Canvaskit engine
//      for plain JS builds — such as `flutter run -d chrome`, which does not
//      emit the wasm artifacts and would otherwise white-screen.
{{flutter_js}}
{{flutter_build_config}}

(function () {
  const BOT_RE =
    /googlebot|bingbot|slurp|duckduckbot|baiduspider|yandexbot|sogou|exabot|facebookexternalhit|facebot|twitterbot|whatsapp|telegrambot|vkShare|pinterest|redditbot|linkedinbot|embedly|quora link preview|ia_archiver|curl|wget|headless/i;

  const userAgent = navigator.userAgent || '';

  // Skip engine startup for crawlers — the edge proxy (Cloudflare Worker)
  // serves those clients pre-rendered HTML snapshots, so the Wasm engine
  // never needs to boot for a bot (and can't white-screen it).
  if (BOT_RE.test(userAgent)) {
    return;
  }

  // Detect whether the host is serving a native-Wasm build. The deployment
  // (flutter build web --wasm + the COOP/COEP headers in firebase.json)
  // serves main.dart.wasm; `flutter run -d chrome` does not, so skwasm is
  // only selected when the wasm artifacts actually exist.
  function wasmBuildAvailable() {
    return fetch('main.dart.wasm', { method: 'HEAD', cache: 'no-store' })
      .then(function (res) { return res.ok; })
      .catch(function () { return false; });
  }

  wasmBuildAvailable().then(function (isWasm) {
    var config = {};
    if (isWasm) {
      config.renderer = 'skwasm';
    }
    _flutter.loader.load({ config: config });
  });
})();
