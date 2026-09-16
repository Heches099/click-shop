// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ClickShop';

  @override
  String get appTagline => 'Real products. Real prices. No tricks.';

  @override
  String get appSubtitle =>
      'Premium fashion, sneakers & electronics at the best prices.';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navSaved => 'Saved';

  @override
  String get navProfile => 'Profile';

  @override
  String get heroTitle => 'Premium Shopping';

  @override
  String get heroSubtitle =>
      'Discover curated collections at unbeatable prices.';

  @override
  String get searchPlaceholder => 'Search products, brands, categories...';

  @override
  String get searchNoResults => 'No results found';

  @override
  String get searchTryDifferent => 'Try a different search term';

  @override
  String get searchOnAmazon => 'Search on Amazon';

  @override
  String get searchPeopleAreSearching => 'People are searching';

  @override
  String get searchRecentSearches => 'Recent searches';

  @override
  String get searchClearAll => 'Clear all';

  @override
  String get searchBrowseCategories => 'Browse categories';

  @override
  String searchResultsFor(Object query) {
    return 'Results for \"$query\"';
  }

  @override
  String get searchAmazonResults => 'From Amazon';

  @override
  String get searchClickShopResults => 'ClickShop Results';

  @override
  String get searchFilters => 'Filters';

  @override
  String get searchSortBy => 'Sort by';

  @override
  String get searchSortRelevance => 'Relevance';

  @override
  String get searchSortPriceLow => 'Price: Low to High';

  @override
  String get searchSortPriceHigh => 'Price: High to Low';

  @override
  String get searchSortNewest => 'Newest';

  @override
  String get searchFilterPrice => 'Price';

  @override
  String get searchFilterBrand => 'Brand';

  @override
  String get searchFilterCategory => 'Category';

  @override
  String get searchFilterSource => 'Source';

  @override
  String get searchFilterAll => 'All';

  @override
  String get searchFilterClickShop => 'ClickShop';

  @override
  String get searchFilterAmazon => 'Amazon';

  @override
  String get searchFilterApply => 'Apply Filters';

  @override
  String get searchFilterClear => 'Clear Filters';

  @override
  String get searchFilterMin => 'Min price';

  @override
  String get searchFilterMax => 'Max price';

  @override
  String get searchEmptyTitle => 'No products match your search';

  @override
  String get searchEmptySubtitle =>
      'Try different keywords or browse our categories.';

  @override
  String get categoryTitle => 'Categories';

  @override
  String get categoryShopAll => 'Shop all';

  @override
  String get categoryShopByCategory => 'Shop by category';

  @override
  String get categoryAll => 'All';

  @override
  String get categorySneakers => 'Sneakers';

  @override
  String get categoryFashion => 'Fashion';

  @override
  String get categoryElectronics => 'Electronics';

  @override
  String get categoryAccessories => 'Accessories';

  @override
  String get productAddToCart => 'Add to Cart';

  @override
  String get productBuyNow => 'Buy Now';

  @override
  String get productSave => 'Save';

  @override
  String get productSaved => 'Saved';

  @override
  String get productCompare => 'Compare';

  @override
  String get productInStock => 'In Stock';

  @override
  String get productLowStock => 'Low Stock';

  @override
  String get productOutOfStock => 'Out of Stock';

  @override
  String get productDetails => 'Details';

  @override
  String get productSpecifications => 'Specifications';

  @override
  String get productRelated => 'You might also like';

  @override
  String get productSimilar => 'Similar products';

  @override
  String get productCheaperAlternatives => 'Lower-priced alternatives';

  @override
  String get productHigherEnd => 'Higher-end alternatives';

  @override
  String get productComplementary => 'Complementary';

  @override
  String get productReviews => 'Reviews';

  @override
  String get productNoReviews => 'No reviews yet';

  @override
  String get productOutOfStockMessage =>
      'This product is currently unavailable.';

  @override
  String get cartTitle => 'Shopping Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartEmptySubtitle => 'Add items to start shopping.';

  @override
  String get cartSubtotal => 'Subtotal';

  @override
  String get cartShipping => 'Shipping';

  @override
  String get cartShippingFree => 'Free';

  @override
  String get cartShippingOver500 => 'Free shipping on orders over \$500';

  @override
  String get cartTotal => 'Total';

  @override
  String get cartCheckout => 'Proceed to Checkout';

  @override
  String get cartClearAll => 'Clear Cart';

  @override
  String get cartRemove => 'Remove';

  @override
  String get cartQty => 'Qty';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutContact => 'Contact Information';

  @override
  String get checkoutShipping => 'Shipping Address';

  @override
  String get checkoutPayment => 'Payment Method';

  @override
  String get checkoutReview => 'Review Order';

  @override
  String get checkoutPlaceOrder => 'Place Order';

  @override
  String get checkoutProcessing => 'Processing...';

  @override
  String get checkoutSuccess => 'Order placed successfully!';

  @override
  String get checkoutEmail => 'Email';

  @override
  String get checkoutPhone => 'Phone';

  @override
  String get checkoutFullName => 'Full Name';

  @override
  String get checkoutAddress => 'Street Address';

  @override
  String get checkoutCity => 'City';

  @override
  String get checkoutState => 'State';

  @override
  String get checkoutZip => 'ZIP Code';

  @override
  String get checkoutCountry => 'Country';

  @override
  String get checkoutCardNumber => 'Card Number';

  @override
  String get checkoutExpiry => 'Expiry Date';

  @override
  String get checkoutCVV => 'CVV';

  @override
  String get checkoutBack => 'Back';

  @override
  String get checkoutNext => 'Next';

  @override
  String get checkoutOrderSummary => 'Order Summary';

  @override
  String get checkoutShippingMethod => 'Shipping Method';

  @override
  String get checkoutStandard => 'Standard Shipping (5-7 days)';

  @override
  String get checkoutExpress => 'Express Shipping (2-3 days)';

  @override
  String get checkoutPaymentApplePay => 'Apple Pay';

  @override
  String get checkoutPaymentCreditCard => 'Credit Card';

  @override
  String get checkoutPaymentPayPal => 'PayPal';

  @override
  String get authLoginTitle => 'Sign In';

  @override
  String get authLoginSubtitle => 'Access your ClickShop account';

  @override
  String get authLoginEmail => 'Email';

  @override
  String get authLoginPassword => 'Password';

  @override
  String get authLoginButton => 'SIGN IN';

  @override
  String get authLoginForgot => 'Forgot Password?';

  @override
  String get authLoginGoogle => 'Continue with Google';

  @override
  String get authLoginNoAccount => 'Don\'t have an account?';

  @override
  String get authLoginSignUp => 'Sign Up';

  @override
  String get authLoginWelcomeBack => 'WELCOME BACK';

  @override
  String get authSignUpTitle => 'Create Account';

  @override
  String get authSignUpSubtitle => 'Join Click Shop and unlock premium access.';

  @override
  String get authSignUpName => 'Full Name';

  @override
  String get authSignUpEmail => 'Email';

  @override
  String get authSignUpPassword => 'Password';

  @override
  String get authSignUpConfirm => 'Confirm Password';

  @override
  String get authSignUpButton => 'CREATE ACCOUNT';

  @override
  String get authSignUpHasAccount => 'Already have an account?';

  @override
  String get authSignUpSignIn => 'Sign In';

  @override
  String get authSignUpCreate => 'SIGN UP';

  @override
  String get authSignUpDetails => 'Enter your details below to get started.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileQuickAccess => 'Quick Access';

  @override
  String get profileCompare => 'Compare';

  @override
  String get profileSaved => 'Saved for later';

  @override
  String get profileAffiliate => 'Affiliate Program';

  @override
  String get profileDiscover => 'Discover';

  @override
  String get profileCollections => 'Collections';

  @override
  String get profileGuides => 'Buying guides';

  @override
  String get profileHelpChoose => 'Help me choose';

  @override
  String get profileOrders => 'Orders';

  @override
  String get profileOwner => 'Owner';

  @override
  String get profileDashboard => 'Owner dashboard';

  @override
  String get profileStoreInfo => 'Store info';

  @override
  String get profileAbout => 'About ClickShop';

  @override
  String get profileContact => 'Contact us';

  @override
  String get profilePrivacy => 'Privacy policy';

  @override
  String get profileTerms => 'Terms of service';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get profileSignIn => 'Sign In';

  @override
  String get profileSignedOut =>
      'Sign in to access your account, orders, and saved items.';

  @override
  String get profileGuest => 'Guest';

  @override
  String get profileClicks => 'Clicks';

  @override
  String get profileSales => 'Sales';

  @override
  String get profileEarned => 'Earned';

  @override
  String get savedTitle => 'Saved';

  @override
  String get savedEmpty => 'No saved items';

  @override
  String get savedEmptySubtitle => 'Items you save will appear here.';

  @override
  String get savedBuyOnAmazon => 'Buy on Amazon';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get ordersEmpty => 'No orders yet';

  @override
  String get ordersEmptySubtitle => 'Your order history will appear here.';

  @override
  String get ordersActive => 'Active';

  @override
  String get ordersCompleted => 'Completed';

  @override
  String get ordersCancelled => 'Cancelled';

  @override
  String get ordersViewDetails => 'View Details';

  @override
  String get ordersTrack => 'Track Order';

  @override
  String get ordersReorder => 'Reorder';

  @override
  String get compareTitle => 'Compare Products';

  @override
  String get compareEmpty => 'No products to compare';

  @override
  String get compareEmptySubtitle =>
      'Add up to 4 products to compare side by side.';

  @override
  String get compareRemove => 'Remove';

  @override
  String get compareAddMore => 'Add more';

  @override
  String get compareIdentical => 'Identical';

  @override
  String get compareDifferences => 'Differences';

  @override
  String get helpTitle => 'Help Me Choose';

  @override
  String get helpSubtitle =>
      'Answer two questions and we\'ll find the right product.';

  @override
  String get helpWhatBuying => 'What are you buying?';

  @override
  String get helpBudget => 'What\'s your budget?';

  @override
  String get helpResults => 'Recommended for you';

  @override
  String get helpNoResults => 'No products found for this selection.';

  @override
  String get helpTryAgain => 'Try different options.';

  @override
  String get helpBack => 'Back';

  @override
  String get helpNext => 'Next';

  @override
  String get helpFinish => 'See results';

  @override
  String get footerShop => 'Shop';

  @override
  String get footerHelp => 'Help';

  @override
  String get footerCompany => 'Company';

  @override
  String get footerLegal => 'Legal';

  @override
  String get aboutTitle => 'About ClickShop';

  @override
  String get contactTitle => 'Contact Us';

  @override
  String get contactName => 'Name';

  @override
  String get contactEmail => 'Email';

  @override
  String get contactSubject => 'Subject';

  @override
  String get contactMessage => 'Message';

  @override
  String get contactSend => 'Send Message';

  @override
  String get contactSuccess => 'Message sent! We\'ll get back to you soon.';

  @override
  String get contactError => 'Failed to send message. Please try again.';

  @override
  String get returnsTitle => 'Returns';

  @override
  String get shippingTitle => 'Shipping';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get termsTitle => 'Terms of Service';

  @override
  String get affiliateTitle => 'Affiliate Program';

  @override
  String get affiliateSubtitle =>
      'Earn commissions by sharing ClickShop products.';

  @override
  String get affiliateSignUp => 'Join Now';

  @override
  String get affiliateDashboard => 'Your Dashboard';

  @override
  String get affiliatePromoCode => 'Promo Code';

  @override
  String get affiliateLink => 'Referral Link';

  @override
  String get affiliateStats => 'Your Stats';

  @override
  String get affiliateCommissions => 'Commissions';

  @override
  String get errorNetwork => 'Network error. Check your connection.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorUnauthorized => 'Please sign in again.';

  @override
  String get errorNotFound => 'Page not found';

  @override
  String get loadingDefault => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get share => 'Share';

  @override
  String get viewAll => 'View all';

  @override
  String get seeMore => 'See more';

  @override
  String get seeLess => 'See less';

  @override
  String get ownerTitle => 'Owner Dashboard';

  @override
  String get ownerRevenue => 'Revenue';

  @override
  String get ownerOrders => 'Orders';

  @override
  String get ownerProducts => 'Products';

  @override
  String get ownerUsers => 'Users';

  @override
  String get ownerLowStock => 'Low stock';

  @override
  String get ownerSalesToday => 'Sales today';

  @override
  String get ownerAnalytics => 'Shopper behaviour';

  @override
  String get ownerInbox => 'Contact inbox';

  @override
  String get ownerAudit => 'Audit trail';

  @override
  String ownerUnread(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread',
      zero: 'No unread',
    );
    return '$_temp0';
  }

  @override
  String get affiliateDisclosure =>
      'As an affiliate, ClickShop may earn a commission from partner links.';

  @override
  String get freeShipping => 'Free shipping on orders over \$500';

  @override
  String get newsletterTitle => 'Stay in the loop';

  @override
  String get newsletterSubtitle => 'Get notified about new products and deals.';

  @override
  String get newsletterPlaceholder => 'Enter your email';

  @override
  String get newsletterButton => 'Subscribe';

  @override
  String get onboardingTitle => 'Welcome to ClickShop';

  @override
  String get onboardingSubtitle => 'Premium fashion, sneakers & electronics';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get signOutConfirmTitle => 'Sign out?';

  @override
  String get signOutConfirmMessage =>
      'You will be signed out of your ClickShop account.';

  @override
  String get clearCartTitle => 'Clear cart?';

  @override
  String get clearCartMessage => 'All items will be removed from your cart.';
}
