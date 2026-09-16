import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/locale_store.dart';

/// Supported app locales. Order matters: the first entry is the fallback
/// used by `flutter gen-l10n` when a device locale has no exact match.
class AppLocales {
  static const List<Locale> supported = [
    Locale('en'),
    Locale('sw'),
    Locale('fr'),
    Locale('ar'),
  ];

  static final Set<String> codes =
      supported.map((l) => l.languageCode).toSet();

  /// True when a locale should render right-to-left.
  static bool isRtl(String languageCode) => languageCode == 'ar';

  /// Returns the best supported locale for a raw code (e.g. `sv` or `ar_EG`),
  /// falling back to English when no compatible language exists.
  static Locale resolve(String? code) {
    if (code == null || code.isEmpty) return const Locale('en');
    final lang = code.split('_').first.split('-').first.toLowerCase();
    if (codes.contains(lang)) return Locale(lang);
    return const Locale('en');
  }
}

/// Tracks the active app locale and persists the user's choice.
final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  final LocaleStore _store = LocaleStore();

  @override
  Locale build() {
    // Best-effort synchronous default: platform locale (web) is read here at
    // startup; a previously persisted choice overrides it asynchronously.
    final platform = WidgetsBinding.instance.platformDispatcher.locale;
    return _resolvedOrDefault(platform.languageCode, persist: false);
  }

  /// Resolves the user's stored preference (called once after Hive is ready)
  /// so a returning visitor keeps their language across sessions. Failures
  /// (e.g. Hive uninitialised in tests) degrade silently to the default.
  Future<void> restore() async {
    try {
      final saved = await _store.load();
      if (saved != null) {
        state = AppLocales.resolve(saved);
      }
    } catch (_) {
      // Ignore: keep the platform-default locale.
    }
  }

  void setLocale(String languageCode) {
    final locale = AppLocales.resolve(languageCode);
    state = locale;
    _store.persist(locale.languageCode);
  }

  Locale _resolvedOrDefault(String code, {required bool persist}) {
    final locale = AppLocales.resolve(code);
    if (persist) _store.persist(locale.languageCode);
    return locale;
  }
}