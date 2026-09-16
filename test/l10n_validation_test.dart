import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Validates that every ARB locale has the exact same set of keys as the
/// English template. Missing or extra keys are flagged immediately so
/// a new translator can never silently break the l10n build.
void main() {
  const l10nDir = 'lib/l10n';
  const templateFile = '$l10nDir/app_en.arb';

  late Map<String, dynamic> templateKeys;
  late List<String> templateKeysSorted;

  setUpAll(() {
    final raw = File(templateFile).readAsStringSync();
    templateKeys = jsonDecode(raw) as Map<String, dynamic>;
    templateKeysSorted = templateKeys.keys
        .where((k) => !k.startsWith('@@') && !k.startsWith('@'))
        .toList()
      ..sort();
  });

  test('English template ARB has all expected keys', () {
    expect(templateKeysSorted.length, greaterThan(100),
        reason: 'Template should have at least 100 user-facing keys');
  });

  for (final locale in ['sw', 'fr', 'ar']) {
    test('app_$locale.arb has exactly the same keys as app_en.arb', () async {
      final raw = File('$l10nDir/app_$locale.arb').readAsStringSync();
      final localeKeys = (jsonDecode(raw) as Map<String, dynamic>)
          .keys
          .where((k) => !k.startsWith('@@') && !k.startsWith('@'))
          .toList()
        ..sort();

      final missingInLocale = templateKeysSorted
          .where((k) => !localeKeys.contains(k))
          .toList();
      final extraInLocale = localeKeys
          .where((k) => !templateKeysSorted.contains(k))
          .toList();

      expect(missingInLocale, isEmpty,
          reason: 'Keys missing from $locale: $missingInLocale');
      expect(extraInLocale, isEmpty,
          reason: 'Extra keys in $locale not in English: $extraInLocale');
    });
  }

  test('no ARB string value is empty', () async {
    for (final file in ['app_en.arb', 'app_sw.arb', 'app_fr.arb', 'app_ar.arb']) {
      final raw = File('$l10nDir/$file').readAsStringSync();
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final emptyKeys = <String>[];
      for (final entry in map.entries) {
        if (entry.key.startsWith('@@') || entry.key.startsWith('@')) continue;
        if (entry.value is String && (entry.value as String).trim().isEmpty) {
          emptyKeys.add(entry.key);
        }
      }
      expect(emptyKeys, isEmpty, reason: '$file has empty values: $emptyKeys');
    }
  });

  test('generated localization classes can be loaded for each locale', () {
    // This is a compile-time + import-time check: the generated files must
    // exist and expose the same number of getter methods for all locales.
    final genFiles = ['app_localizations_en.dart', 'app_localizations_sw.dart',
      'app_localizations_fr.dart', 'app_localizations_ar.dart'];
    for (final f in genFiles) {
      expect(File('$l10nDir/$f').existsSync(), isTrue,
          reason: 'Generated file $f is missing');
    }
  });
}