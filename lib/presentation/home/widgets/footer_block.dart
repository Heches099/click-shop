import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/business_info.dart';
import '../../../config/design_tokens.dart';
import '../../../l10n/app_localizations.dart';

/// Honest, consistent site footer: trust links + contact + disclosure.
class FooterBlock extends StatelessWidget {
  const FooterBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final links = <(String, String)>[
      (l10n.profileCollections, '/collections'),
      (l10n.profileGuides, '/guides'),
      (l10n.profileCompare, '/compare'),
      (l10n.profileHelpChoose, '/help-me-choose'),
      (l10n.profileAffiliate, '/affiliate'),
    ];
    final info = <(String, String)>[
      (l10n.aboutTitle, '/about'),
      (l10n.profileContact, '/contact'),
      (l10n.returnsTitle, '/returns'),
      (l10n.shippingTitle, '/shipping'),
      (l10n.profilePrivacy, '/privacy'),
      (l10n.profileTerms, '/terms'),
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFF121212),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(BusinessInfo.name,
              style: AppTypography.titleMedium.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            BusinessInfo.tagline,
            style: AppTypography.caption.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          _linkCol(l10n.footerShop, links, context),
          const SizedBox(height: 18),
          _linkCol(l10n.profileStoreInfo, info, context),
          const SizedBox(height: 18),
          Text('Email: ${BusinessInfo.supportEmail}',
              style: AppTypography.caption.copyWith(color: Colors.white70)),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          Text(
            'Affiliate disclosure: some "Buy on Amazon" links are affiliate '
            'links — ClickShop may earn a commission at no extra cost to you.',
            style: AppTypography.caption.copyWith(color: Colors.white54, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _linkCol(String title, List<(String, String)> links, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTypography.caption.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 22,
          runSpacing: 8,
          children: links
              .map((l) => GestureDetector(
                    onTap: () => context.push(l.$2),
                    child: Text(l.$1,
                        style: AppTypography.caption
                            .copyWith(color: Colors.white70)),
                  ))
              .toList(),
        ),
      ],
    );
  }
}