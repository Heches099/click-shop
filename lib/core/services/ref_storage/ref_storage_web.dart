/// Web (JS + Wasm) implementation of [RefStorage] backed by localStorage.
library;

import 'package:web/web.dart' as web;

const _key = 'affiliate_ref_code';

Future<String?> getRef() async => web.window.localStorage.getItem(_key);

Future<void> setRef(String? code) async {
  if (code == null || code.trim().isEmpty) {
    web.window.localStorage.removeItem(_key);
  } else {
    web.window.localStorage.setItem(_key, code.trim());
  }
}
