import 'package:hive_flutter/hive_flutter.dart';

/// Persists the user's selected app locale across sessions via Hive,
/// following the same pattern used by the other lightweight stores.
class LocaleStore {
  static const _boxName = 'settings_box';
  static const _key = 'locale';

  Box<String>? _box;

  Future<Box<String>> _getBox() async {
    _box ??= await Hive.openBox<String>(_boxName);
    return _box!;
  }

  Future<String?> load() async {
    return (await _getBox()).get(_key);
  }

  Future<void> persist(String localeCode) async {
    await (await _getBox()).put(_key, localeCode);
  }
}