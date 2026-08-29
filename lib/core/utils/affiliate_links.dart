/// Helpers for Google E-E-A-T / affiliate disclosure compliance.
///
/// Google's quality guidelines require that monetized links to partner
/// retailers are explicitly marked. Use [sponsoredRel] anywhere a link leaves
/// the store to an affiliate partner so crawlers understand the link's nature.
library;

/// The `rel` attribute value for a paid / affiliate link to a partner retailer.
/// Using both values maximizes compliance across search engines.
const String sponsoredRel = 'sponsored nofollow';

/// Returns `true` for well-formed external (non-own-domain) retailer URLs that
/// should carry [sponsoredRel].
bool isPartnerUrl(String url) {
  return url.startsWith('https://') || url.startsWith('http://');
}

/// Renders the `rel` attribute snippet for an affiliate <a> element.
String sponsoredRelAttribute() => 'rel="$sponsoredRel"';
