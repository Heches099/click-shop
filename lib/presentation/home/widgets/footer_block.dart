import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/business_info.dart';
import '../../../config/design_tokens.dart';

/// Honest, consistent site footer: trust links + contact + disclosure.
class FooterBlock extends StatelessWidget {
  const FooterBlock({super.key});

  static const _links = <(String, String)>[
    ('Collections', '/collections'),
    ('Guides', '/guides'),
    ('Compare', '/compare'),
    ('Help me choose', '/help-me-choose'),
    ('Affiliate program', '/affiliate'),
  ];

  static const _info = <(String, String)>[
    ('About', '/about'),
    ('Contact', '/contact'),
    ('Returns', '/returns'),
    ('Shipping', '/shipping'),
    ('Privacy', '/privacy'),
    ('Terms', '/terms'),
  ];

  @override
  Widget build(BuildContext context) {
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
          _linkCol('Shop', _links, context),
          const SizedBox(height: 18),
          _linkCol('Store info', _info, context),
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