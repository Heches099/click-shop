import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Persisted recent search queries (Hive), capped and de-duplicated.
class SearchHistoryStore {
  Box<String>? _box;

  static const int _max = 8;

  Future<Box<String>> _getBox() async {
    _box ??= await Hive.openBox<String>('search_history');
    return _box!;
  }

  List<String>? load() {
    // Synchronous read during provider build; box opens lazily & async, so we
    // fall back to empty until the box is available (non-fatal).
    final box = _box;
    if (box == null) return const [];
    try {
      final raw = box.get('items');
      if (raw == null || raw.trim().isEmpty) return const [];
      return (jsonDecode(raw) as List<dynamic>).cast<String>();
    } catch (_) {
      return const [];
    }
  }

  List<String> add(String query) {
    final current = List<String>.from(load() ?? const []);
    final next = [query, ...current.where((s) => s != query)].take(_max).toList();
    _persist(next);
    return next;
  }

  List<String> remove(String query) {
    final next = List<String>.from(load() ?? const []).where((s) => s != query).toList();
    _persist(next);
    return next;
  }

  List<String> clear() {
    _persist(const []);
    return const [];
  }

  Future<void> _persist(List<String> items) async {
    try {
      await (await _getBox()).put('items', jsonEncode(items));
    } catch (_) {
      // History is a nice-to-have; never crash on storage failure.
    }
  }
}