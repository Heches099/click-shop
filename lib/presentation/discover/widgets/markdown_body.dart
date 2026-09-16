import 'package:flutter/material.dart';
import '../../../../config/design_tokens.dart';

/// A deliberately small markdown renderer for buying-guide bodies:
/// headings (`##`/`###`/`####`), bold (`**...**`), bullet lists (`- `),
/// numbered lists (`1. `) and paragraphs. Kept local & dependency-free so
/// guides always render even with zero extra packages.
class MarkdownBody extends StatelessWidget {
  final String markdown;
  const MarkdownBody({super.key, required this.markdown});

  @override
  Widget build(BuildContext context) {
    final lines = markdown.split('\n');
    final blocks = <Widget>[];
    var inList = false;
    var listIsNumbered = false;

    void pushList(String text, {bool numbered = false}) {
      final dot = numbered ? '•' : '•';
      blocks.add(Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dot,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.accent)),
            const SizedBox(width: 10),
            Expanded(
              child: _Rich(line: text),
            ),
          ],
        ),
      ));
    }

    for (final raw in lines) {
      final line = raw.trimRight();
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final bulletMatch = RegExp(r'^[-*]\s+(.*)$').firstMatch(trimmed);
      final numberedMatch = RegExp(r'^\d+[.)]\s+(.*)$').firstMatch(trimmed);

      if (bulletMatch != null || numberedMatch != null) {
        if (!inList) {
          blocks.add(const SizedBox(height: 6));
          inList = true;
        }
        listIsNumbered = numberedMatch != null;
        pushList(
          (numberedMatch ?? bulletMatch)!.group(1)!,
          numbered: listIsNumbered,
        );
        continue;
      }
      inList = false;

      // Headings
      final heading = RegExp(r'^(#{1,4})\s+(.*)$').firstMatch(trimmed);
      if (heading != null) {
        final level = heading.group(1)!.length;
        blocks.add(Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 6),
          child: _Rich(
            line: heading.group(2)!,
            style: level <= 2
                ? AppTypography.titleLarge
                : AppTypography.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600),
          ),
        ));
        continue;
      }

      // Horizontal rule
      if (RegExp(r'^\s*(-{3,}|\*{3,})\s*$').hasMatch(trimmed)) {
        blocks.add(const Divider(height: 28, color: AppColors.divider));
        continue;
      }

      // Inline code
      if (trimmed.length >= 2 &&
          trimmed.startsWith('`') &&
          trimmed.endsWith('`')) {
        blocks.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              trimmed.substring(1, trimmed.length - 1),
              style: AppTypography.bodyMedium.copyWith(fontFamily: 'monospace'),
            ),
          ),
        ));
        continue;
      }

      blocks.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: _Rich(line: line),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks,
    );
  }
}

class _Rich extends StatelessWidget {
  final String line;
  final TextStyle? style;
  const _Rich({required this.line, this.style});

  @override
  Widget build(BuildContext context) {
    final baseStyle = (style ?? AppTypography.bodyMedium)
        .copyWith(height: 1.6, color: AppColors.textPrimary);
    // Split on **bold** segments only (our guides use no other inline syntax).
    final parts = line.split(RegExp(r'(\*\*[^*]+\*\*)'));
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: parts.map((part) {
          if (part.startsWith('**') && part.endsWith('**') && part.length > 4) {
            return TextSpan(
              text: part.substring(2, part.length - 2),
              style: baseStyle.copyWith(fontWeight: FontWeight.w700),
            );
          }
          return TextSpan(text: part);
        }).toList(),
      ),
    );
  }
}