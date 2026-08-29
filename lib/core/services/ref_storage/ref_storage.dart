import 'ref_storage_native.dart'
    if (dart.library.js_interop) 'ref_storage_web.dart' as impl;

/// Tiny key/value store used to persist the affiliate referral code for the
/// current session/user.
///
/// The web implementation uses `window.localStorage` through `package:web`,
/// so it works in both JS and Wasm/Skwasm builds. (Hive's web backend depends
/// on `dart:html`, which is unavailable under `--wasm`, so it cannot be used
/// on web.)
class RefStorage {
  const RefStorage._();

  static const RefStorage instance = RefStorage._();

  Future<String?> getRef() => impl.getRef();

  Future<void> setRef(String? code) => impl.setRef(code);
}
