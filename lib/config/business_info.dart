/// Static business identity used by the footer, About, Contact and trust pages.
/// Centralised so every "Contact us" mentions the same email, etc.
class BusinessInfo {
  static const String name = 'ClickShop';
  static const String tagline = 'Discover. Compare. Choose with confidence.';
  static const String supportEmail = 'support@clickshop.com';
  static const String foundIn = 'Built for curious shoppers.';
  static const String baseUrl = 'https://click-shop-669d.onrender.com/v1';
  static const String storeUrl = 'https://click-shop-d62ad.web.app';

  /// Human-written, factual copy for the info pages. No invented promises.
  static const Map<String, (String, String)> infoPages = {
    'about': (
      'About ClickShop',
      'ClickShop is a curated online store that helps you discover products, '
          'compare the ones you are shortlisting, and decide with confidence.\n\n'
          'We do not rank shops or invent "best sellers". We show honest '
          'alternatives — similar items, cheaper options, higher-end options — '
          'and explain what actually matters so the choice is yours.\n\n'
          'Every item on the catalog has a real price drawn from our store '
          'data, real product information, and no fabricated discounts, '
          'countdown timers or urgency. If a product is fulfilled by Amazon, '
          'we say so and link through our affiliate program with full '
          'disclosure.\n\n'
          'Shop the curated collections, use the Compare tool to line up your '
          'finalists, and read the Buying Guides when you want to understand '
          'what to look for before you buy.',
    ),
    'contact': (
      'Contact us',
      'Have a question about an order, a product or an affiliate partnership? '
          'Use the contact form on our Contact page and our team will reply '
          'to your email address.\n\n'
          'For order questions, please include your order number if you have '
          'one — it helps us find your order faster.\n\n'
          'Email: support@clickshop.com',
    ),
    'returns': (
      'Returns & refunds',
      'We want you to be happy with what you bought. If something is wrong — '
          'a sizing issue, a defect, or the item simply does not fit — contact '
          'support within 14 days of receiving your order with your order '
          'number and we will take it from there.\n\n'
          'Refunds are issued back to the original payment method once the '
          'return is confirmed. Items should be returned in their original '
          'condition and packaging where possible.\n\n'
          'Products fulfilled by Amazon follow Amazon\'s own returns policy, '
          'which is handled directly with Amazon.',
    ),
    'shipping': (
      'Shipping & delivery',
      'Orders from the ClickShop catalog ship through our fulfilment '
          'partners. Delivery times and costs in your region are shown at '
          'checkout before you pay, so there are never surprise charges.\n\n'
          'You will receive tracking details once your order ships. For '
          'Amazon-fulfilled products, shipping and delivery are handled by '
          'Amazon, and their timelines apply.',
    ),
    'privacy': (
      'Privacy policy',
      'We collect only what we need to run the store: your account details, '
          'your orders and your shipping address.\n\n'
          'With your permission we keep encrypted payment details for '
          'checkout. We never sell your personal data to anyone.\n\n'
          'Anonymous, aggregate analytics help us understand what shoppers '
          'search for and view — genuine product interest only, never '
          'personal tracking for advertising.',
    ),
    'terms': (
      'Terms of service',
      'By using ClickShop you agree to these terms.\n\n'
          'Prices, availability and product information can change and are '
          'shown at the time of purchase. We work hard to keep the catalog '
          'accurate and honest.\n\n'
          'Affiliate disclosure: some "Buy on Amazon" links are affiliate '
          'links, which means ClickShop may earn a commission if you buy '
          'through them — at no extra cost to you. We only link products we '
          'stand behind and we clearly disclose this.\n\n'
          'For product issues, contact support at support@clickshop.com.',
    ),
  };
}