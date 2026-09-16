import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';

/// Compact language switcher shown in app bars. Uses the localised name of
/// each language so every visitor can find their tongue immediately.
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);
    final selected = current.languageCode;

    return compact
        ? PopupMenuButton<String>(
            tooltip: 'Language',
            initialValue: selected,
            onSelected: (code) =>
                ref.read(localeProvider.notifier).setLocale(code),
            icon: Icon(
              Icons.language_rounded,
              size: 22,
              color: Theme.of(context).iconTheme.color,
            ),
            itemBuilder: (context) => _items(selected),
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
              ),
            ),
            child: PopupMenuButton<String>(
              tooltip: 'Language',
              initialValue: selected,
              onSelected: (code) =>
                  ref.read(localeProvider.notifier).setLocale(code),
              color: Theme.of(context).colorScheme.surface,
              offset: const Offset(0, 44),
              itemBuilder: (context) => _items(selected),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.language_rounded,
                    size: 18,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _displayName(selected),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down_rounded, size: 18),
                ],
              ),
            ),
          );
  }

  List<PopupMenuEntry<String>> _items(String selected) {
    return const [
      PopupMenuItem(value: 'en', child: _LangRow('en', 'English')),
      PopupMenuItem(value: 'sw', child: _LangRow('sw', 'Kiswahili')),
      PopupMenuItem(value: 'fr', child: _LangRow('fr', 'Français')),
      PopupMenuItem(value: 'ar', child: _LangRow('ar', 'العربية')),
    ];
  }

  String _displayName(String code) {
    switch (code) {
      case 'sw':
        return 'Kiswahili';
      case 'fr':
        return 'FR';
      case 'ar':
        return 'عربية';
      default:
        return 'EN';
    }
  }
}

class _LangRow extends ConsumerWidget {
  const _LangRow(this.code, this.label);

  final String code;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(localeProvider).languageCode == code;
    return Row(
      children: [
        Text(
          code.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).iconTheme.color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        if (isSelected)
          const Icon(Icons.check_rounded, size: 18, color: Colors.green),
      ],
    );
  }
}