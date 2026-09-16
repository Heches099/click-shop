import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('fr'),
    Locale('sw')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ClickShop'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Real products. Real prices. No tricks.'**
  String get appTagline;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Premium fashion, sneakers & electronics at the best prices.'**
  String get appSubtitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navSaved;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Shopping'**
  String get heroTitle;

  /// No description provided for @heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover curated collections at unbeatable prices.'**
  String get heroSubtitle;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search products, brands, categories...'**
  String get searchPlaceholder;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchNoResults;

  /// No description provided for @searchTryDifferent.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get searchTryDifferent;

  /// No description provided for @searchOnAmazon.
  ///
  /// In en, this message translates to:
  /// **'Search on Amazon'**
  String get searchOnAmazon;

  /// No description provided for @searchPeopleAreSearching.
  ///
  /// In en, this message translates to:
  /// **'People are searching'**
  String get searchPeopleAreSearching;

  /// No description provided for @searchRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchRecentSearches;

  /// No description provided for @searchClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get searchClearAll;

  /// No description provided for @searchBrowseCategories.
  ///
  /// In en, this message translates to:
  /// **'Browse categories'**
  String get searchBrowseCategories;

  /// No description provided for @searchResultsFor.
  ///
  /// In en, this message translates to:
  /// **'Results for \"{query}\"'**
  String searchResultsFor(Object query);

  /// No description provided for @searchAmazonResults.
  ///
  /// In en, this message translates to:
  /// **'From Amazon'**
  String get searchAmazonResults;

  /// No description provided for @searchClickShopResults.
  ///
  /// In en, this message translates to:
  /// **'ClickShop Results'**
  String get searchClickShopResults;

  /// No description provided for @searchFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get searchFilters;

  /// No description provided for @searchSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get searchSortBy;

  /// No description provided for @searchSortRelevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get searchSortRelevance;

  /// No description provided for @searchSortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get searchSortPriceLow;

  /// No description provided for @searchSortPriceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get searchSortPriceHigh;

  /// No description provided for @searchSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get searchSortNewest;

  /// No description provided for @searchFilterPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get searchFilterPrice;

  /// No description provided for @searchFilterBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get searchFilterBrand;

  /// No description provided for @searchFilterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get searchFilterCategory;

  /// No description provided for @searchFilterSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get searchFilterSource;

  /// No description provided for @searchFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchFilterAll;

  /// No description provided for @searchFilterClickShop.
  ///
  /// In en, this message translates to:
  /// **'ClickShop'**
  String get searchFilterClickShop;

  /// No description provided for @searchFilterAmazon.
  ///
  /// In en, this message translates to:
  /// **'Amazon'**
  String get searchFilterAmazon;

  /// No description provided for @searchFilterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get searchFilterApply;

  /// No description provided for @searchFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get searchFilterClear;

  /// No description provided for @searchFilterMin.
  ///
  /// In en, this message translates to:
  /// **'Min price'**
  String get searchFilterMin;

  /// No description provided for @searchFilterMax.
  ///
  /// In en, this message translates to:
  /// **'Max price'**
  String get searchFilterMax;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No products match your search'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords or browse our categories.'**
  String get searchEmptySubtitle;

  /// No description provided for @categoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoryTitle;

  /// No description provided for @categoryShopAll.
  ///
  /// In en, this message translates to:
  /// **'Shop all'**
  String get categoryShopAll;

  /// No description provided for @categoryShopByCategory.
  ///
  /// In en, this message translates to:
  /// **'Shop by category'**
  String get categoryShopByCategory;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categorySneakers.
  ///
  /// In en, this message translates to:
  /// **'Sneakers'**
  String get categorySneakers;

  /// No description provided for @categoryFashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get categoryFashion;

  /// No description provided for @categoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// No description provided for @categoryAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get categoryAccessories;

  /// No description provided for @productAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get productAddToCart;

  /// No description provided for @productBuyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get productBuyNow;

  /// No description provided for @productSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get productSave;

  /// No description provided for @productSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get productSaved;

  /// No description provided for @productCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get productCompare;

  /// No description provided for @productInStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get productInStock;

  /// No description provided for @productLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get productLowStock;

  /// No description provided for @productOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get productOutOfStock;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get productDetails;

  /// No description provided for @productSpecifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get productSpecifications;

  /// No description provided for @productRelated.
  ///
  /// In en, this message translates to:
  /// **'You might also like'**
  String get productRelated;

  /// No description provided for @productSimilar.
  ///
  /// In en, this message translates to:
  /// **'Similar products'**
  String get productSimilar;

  /// No description provided for @productCheaperAlternatives.
  ///
  /// In en, this message translates to:
  /// **'Lower-priced alternatives'**
  String get productCheaperAlternatives;

  /// No description provided for @productHigherEnd.
  ///
  /// In en, this message translates to:
  /// **'Higher-end alternatives'**
  String get productHigherEnd;

  /// No description provided for @productComplementary.
  ///
  /// In en, this message translates to:
  /// **'Complementary'**
  String get productComplementary;

  /// No description provided for @productReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get productReviews;

  /// No description provided for @productNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get productNoReviews;

  /// No description provided for @productOutOfStockMessage.
  ///
  /// In en, this message translates to:
  /// **'This product is currently unavailable.'**
  String get productOutOfStockMessage;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @cartEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add items to start shopping.'**
  String get cartEmptySubtitle;

  /// No description provided for @cartSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cartSubtotal;

  /// No description provided for @cartShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get cartShipping;

  /// No description provided for @cartShippingFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get cartShippingFree;

  /// No description provided for @cartShippingOver500.
  ///
  /// In en, this message translates to:
  /// **'Free shipping on orders over \$500'**
  String get cartShippingOver500;

  /// No description provided for @cartTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cartTotal;

  /// No description provided for @cartCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get cartCheckout;

  /// No description provided for @cartClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get cartClearAll;

  /// No description provided for @cartRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get cartRemove;

  /// No description provided for @cartQty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get cartQty;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @checkoutContact.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get checkoutContact;

  /// No description provided for @checkoutShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get checkoutShipping;

  /// No description provided for @checkoutPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get checkoutPayment;

  /// No description provided for @checkoutReview.
  ///
  /// In en, this message translates to:
  /// **'Review Order'**
  String get checkoutReview;

  /// No description provided for @checkoutPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get checkoutPlaceOrder;

  /// No description provided for @checkoutProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get checkoutProcessing;

  /// No description provided for @checkoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully!'**
  String get checkoutSuccess;

  /// No description provided for @checkoutEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get checkoutEmail;

  /// No description provided for @checkoutPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get checkoutPhone;

  /// No description provided for @checkoutFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get checkoutFullName;

  /// No description provided for @checkoutAddress.
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get checkoutAddress;

  /// No description provided for @checkoutCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get checkoutCity;

  /// No description provided for @checkoutState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get checkoutState;

  /// No description provided for @checkoutZip.
  ///
  /// In en, this message translates to:
  /// **'ZIP Code'**
  String get checkoutZip;

  /// No description provided for @checkoutCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get checkoutCountry;

  /// No description provided for @checkoutCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get checkoutCardNumber;

  /// No description provided for @checkoutExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get checkoutExpiry;

  /// No description provided for @checkoutCVV.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get checkoutCVV;

  /// No description provided for @checkoutBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get checkoutBack;

  /// No description provided for @checkoutNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get checkoutNext;

  /// No description provided for @checkoutOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get checkoutOrderSummary;

  /// No description provided for @checkoutShippingMethod.
  ///
  /// In en, this message translates to:
  /// **'Shipping Method'**
  String get checkoutShippingMethod;

  /// No description provided for @checkoutStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard Shipping (5-7 days)'**
  String get checkoutStandard;

  /// No description provided for @checkoutExpress.
  ///
  /// In en, this message translates to:
  /// **'Express Shipping (2-3 days)'**
  String get checkoutExpress;

  /// No description provided for @checkoutPaymentApplePay.
  ///
  /// In en, this message translates to:
  /// **'Apple Pay'**
  String get checkoutPaymentApplePay;

  /// No description provided for @checkoutPaymentCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get checkoutPaymentCreditCard;

  /// No description provided for @checkoutPaymentPayPal.
  ///
  /// In en, this message translates to:
  /// **'PayPal'**
  String get checkoutPaymentPayPal;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access your ClickShop account'**
  String get authLoginSubtitle;

  /// No description provided for @authLoginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authLoginEmail;

  /// No description provided for @authLoginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authLoginPassword;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get authLoginButton;

  /// No description provided for @authLoginForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authLoginForgot;

  /// No description provided for @authLoginGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authLoginGoogle;

  /// No description provided for @authLoginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authLoginNoAccount;

  /// No description provided for @authLoginSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authLoginSignUp;

  /// No description provided for @authLoginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'WELCOME BACK'**
  String get authLoginWelcomeBack;

  /// No description provided for @authSignUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authSignUpTitle;

  /// No description provided for @authSignUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join Click Shop and unlock premium access.'**
  String get authSignUpSubtitle;

  /// No description provided for @authSignUpName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authSignUpName;

  /// No description provided for @authSignUpEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authSignUpEmail;

  /// No description provided for @authSignUpPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authSignUpPassword;

  /// No description provided for @authSignUpConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authSignUpConfirm;

  /// No description provided for @authSignUpButton.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get authSignUpButton;

  /// No description provided for @authSignUpHasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authSignUpHasAccount;

  /// No description provided for @authSignUpSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignUpSignIn;

  /// No description provided for @authSignUpCreate.
  ///
  /// In en, this message translates to:
  /// **'SIGN UP'**
  String get authSignUpCreate;

  /// No description provided for @authSignUpDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter your details below to get started.'**
  String get authSignUpDetails;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileQuickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get profileQuickAccess;

  /// No description provided for @profileCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get profileCompare;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved for later'**
  String get profileSaved;

  /// No description provided for @profileAffiliate.
  ///
  /// In en, this message translates to:
  /// **'Affiliate Program'**
  String get profileAffiliate;

  /// No description provided for @profileDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get profileDiscover;

  /// No description provided for @profileCollections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get profileCollections;

  /// No description provided for @profileGuides.
  ///
  /// In en, this message translates to:
  /// **'Buying guides'**
  String get profileGuides;

  /// No description provided for @profileHelpChoose.
  ///
  /// In en, this message translates to:
  /// **'Help me choose'**
  String get profileHelpChoose;

  /// No description provided for @profileOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get profileOrders;

  /// No description provided for @profileOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get profileOwner;

  /// No description provided for @profileDashboard.
  ///
  /// In en, this message translates to:
  /// **'Owner dashboard'**
  String get profileDashboard;

  /// No description provided for @profileStoreInfo.
  ///
  /// In en, this message translates to:
  /// **'Store info'**
  String get profileStoreInfo;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About ClickShop'**
  String get profileAbout;

  /// No description provided for @profileContact.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get profileContact;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get profilePrivacy;

  /// No description provided for @profileTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get profileTerms;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @profileSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get profileSignIn;

  /// No description provided for @profileSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your account, orders, and saved items.'**
  String get profileSignedOut;

  /// No description provided for @profileGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileGuest;

  /// No description provided for @profileClicks.
  ///
  /// In en, this message translates to:
  /// **'Clicks'**
  String get profileClicks;

  /// No description provided for @profileSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get profileSales;

  /// No description provided for @profileEarned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get profileEarned;

  /// No description provided for @savedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedTitle;

  /// No description provided for @savedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved items'**
  String get savedEmpty;

  /// No description provided for @savedEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Items you save will appear here.'**
  String get savedEmptySubtitle;

  /// No description provided for @savedBuyOnAmazon.
  ///
  /// In en, this message translates to:
  /// **'Buy on Amazon'**
  String get savedBuyOnAmazon;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @ordersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmpty;

  /// No description provided for @ordersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your order history will appear here.'**
  String get ordersEmptySubtitle;

  /// No description provided for @ordersActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ordersActive;

  /// No description provided for @ordersCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ordersCompleted;

  /// No description provided for @ordersCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ordersCancelled;

  /// No description provided for @ordersViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get ordersViewDetails;

  /// No description provided for @ordersTrack.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get ordersTrack;

  /// No description provided for @ordersReorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get ordersReorder;

  /// No description provided for @compareTitle.
  ///
  /// In en, this message translates to:
  /// **'Compare Products'**
  String get compareTitle;

  /// No description provided for @compareEmpty.
  ///
  /// In en, this message translates to:
  /// **'No products to compare'**
  String get compareEmpty;

  /// No description provided for @compareEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add up to 4 products to compare side by side.'**
  String get compareEmptySubtitle;

  /// No description provided for @compareRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get compareRemove;

  /// No description provided for @compareAddMore.
  ///
  /// In en, this message translates to:
  /// **'Add more'**
  String get compareAddMore;

  /// No description provided for @compareIdentical.
  ///
  /// In en, this message translates to:
  /// **'Identical'**
  String get compareIdentical;

  /// No description provided for @compareDifferences.
  ///
  /// In en, this message translates to:
  /// **'Differences'**
  String get compareDifferences;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help Me Choose'**
  String get helpTitle;

  /// No description provided for @helpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Answer two questions and we\'ll find the right product.'**
  String get helpSubtitle;

  /// No description provided for @helpWhatBuying.
  ///
  /// In en, this message translates to:
  /// **'What are you buying?'**
  String get helpWhatBuying;

  /// No description provided for @helpBudget.
  ///
  /// In en, this message translates to:
  /// **'What\'s your budget?'**
  String get helpBudget;

  /// No description provided for @helpResults.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get helpResults;

  /// No description provided for @helpNoResults.
  ///
  /// In en, this message translates to:
  /// **'No products found for this selection.'**
  String get helpNoResults;

  /// No description provided for @helpTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try different options.'**
  String get helpTryAgain;

  /// No description provided for @helpBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get helpBack;

  /// No description provided for @helpNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get helpNext;

  /// No description provided for @helpFinish.
  ///
  /// In en, this message translates to:
  /// **'See results'**
  String get helpFinish;

  /// No description provided for @footerShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get footerShop;

  /// No description provided for @footerHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get footerHelp;

  /// No description provided for @footerCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get footerCompany;

  /// No description provided for @footerLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get footerLegal;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About ClickShop'**
  String get aboutTitle;

  /// No description provided for @contactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactTitle;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get contactName;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contactEmail;

  /// No description provided for @contactSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get contactSubject;

  /// No description provided for @contactMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get contactMessage;

  /// No description provided for @contactSend.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get contactSend;

  /// No description provided for @contactSuccess.
  ///
  /// In en, this message translates to:
  /// **'Message sent! We\'ll get back to you soon.'**
  String get contactSuccess;

  /// No description provided for @contactError.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message. Please try again.'**
  String get contactError;

  /// No description provided for @returnsTitle.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get returnsTitle;

  /// No description provided for @shippingTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shippingTitle;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsTitle;

  /// No description provided for @affiliateTitle.
  ///
  /// In en, this message translates to:
  /// **'Affiliate Program'**
  String get affiliateTitle;

  /// No description provided for @affiliateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Earn commissions by sharing ClickShop products.'**
  String get affiliateSubtitle;

  /// No description provided for @affiliateSignUp.
  ///
  /// In en, this message translates to:
  /// **'Join Now'**
  String get affiliateSignUp;

  /// No description provided for @affiliateDashboard.
  ///
  /// In en, this message translates to:
  /// **'Your Dashboard'**
  String get affiliateDashboard;

  /// No description provided for @affiliatePromoCode.
  ///
  /// In en, this message translates to:
  /// **'Promo Code'**
  String get affiliatePromoCode;

  /// No description provided for @affiliateLink.
  ///
  /// In en, this message translates to:
  /// **'Referral Link'**
  String get affiliateLink;

  /// No description provided for @affiliateStats.
  ///
  /// In en, this message translates to:
  /// **'Your Stats'**
  String get affiliateStats;

  /// No description provided for @affiliateCommissions.
  ///
  /// In en, this message translates to:
  /// **'Commissions'**
  String get affiliateCommissions;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again.'**
  String get errorUnauthorized;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get errorNotFound;

  /// No description provided for @loadingDefault.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingDefault;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get seeMore;

  /// No description provided for @seeLess.
  ///
  /// In en, this message translates to:
  /// **'See less'**
  String get seeLess;

  /// No description provided for @ownerTitle.
  ///
  /// In en, this message translates to:
  /// **'Owner Dashboard'**
  String get ownerTitle;

  /// No description provided for @ownerRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get ownerRevenue;

  /// No description provided for @ownerOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ownerOrders;

  /// No description provided for @ownerProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get ownerProducts;

  /// No description provided for @ownerUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get ownerUsers;

  /// No description provided for @ownerLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get ownerLowStock;

  /// No description provided for @ownerSalesToday.
  ///
  /// In en, this message translates to:
  /// **'Sales today'**
  String get ownerSalesToday;

  /// No description provided for @ownerAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Shopper behaviour'**
  String get ownerAnalytics;

  /// No description provided for @ownerInbox.
  ///
  /// In en, this message translates to:
  /// **'Contact inbox'**
  String get ownerInbox;

  /// No description provided for @ownerAudit.
  ///
  /// In en, this message translates to:
  /// **'Audit trail'**
  String get ownerAudit;

  /// No description provided for @ownerUnread.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No unread} other{{count} unread}}'**
  String ownerUnread(num count);

  /// No description provided for @affiliateDisclosure.
  ///
  /// In en, this message translates to:
  /// **'As an affiliate, ClickShop may earn a commission from partner links.'**
  String get affiliateDisclosure;

  /// No description provided for @freeShipping.
  ///
  /// In en, this message translates to:
  /// **'Free shipping on orders over \$500'**
  String get freeShipping;

  /// No description provided for @newsletterTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay in the loop'**
  String get newsletterTitle;

  /// No description provided for @newsletterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified about new products and deals.'**
  String get newsletterSubtitle;

  /// No description provided for @newsletterPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get newsletterPlaceholder;

  /// No description provided for @newsletterButton.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get newsletterButton;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to ClickShop'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Premium fashion, sneakers & electronics'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You will be signed out of your ClickShop account.'**
  String get signOutConfirmMessage;

  /// No description provided for @clearCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear cart?'**
  String get clearCartTitle;

  /// No description provided for @clearCartMessage.
  ///
  /// In en, this message translates to:
  /// **'All items will be removed from your cart.'**
  String get clearCartMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
