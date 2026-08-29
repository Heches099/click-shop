/// Native (non-web) implementation of [RefStorage] backed by Hive.
library;

import 'package:hive_flutter/hive_flutter.dart';

const _boxName = 'affiliate_ref_box';
const _key = 'ref';

Future<String?> getRef() async {
  final box = await Hive.openBox<String>(_boxName);
  return box.get(_key);
}

Future<void> setRef(String? code) async {
  final box = await Hive.openBox<String>(_boxName);
  if (code == null || code.trim().isEmpty) {
    await box.delete(_key);
  } else {
    await box.put(_key, code.trim());
  }
}
