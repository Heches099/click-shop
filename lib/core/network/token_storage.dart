import 'package:hive_flutter/hive_flutter.dart';

/// Persists the ClickShop API JWT obtained by exchanging a Firebase ID token
/// at `POST /auth/firebase`. The box is intentionally opened during service
/// locator init so the Dio auth interceptor can read it synchronously.
class TokenStorage {
  static const String _boxName = 'api_token_box';
  static const String _key = 'api_jwt';

  Box<String>? _box;

  Future<Box<String>> _open() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<String>(_boxName);
    return _box!;
  }

  /// Called during app startup so the box is ready for sync reads.
  Future<void> open() async => _open();

  /// Synchronous read for interceptors — only valid after [open()].
  String? readSync() {
    final box = _box;
    if (box == null || !box.isOpen) return null;
    return box.get(_key);
  }

  Future<String?> read() async {
    final box = await _open();
    return box.get(_key);
  }

  Future<void> write(String token) async {
    final box = await _open();
    await box.put(_key, token);
  }

  Future<void> clear() async {
    final box = await _open();
    await box.delete(_key);
  }
}