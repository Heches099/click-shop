// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'ClickShop';

  @override
  String get appTagline => 'Bidhaa halisi. Bei halisi. Hakuna mchezo.';

  @override
  String get appSubtitle =>
      'Mitindo ya premium, viatu na elektroniki kwa bei bora.';

  @override
  String get navHome => 'Nyumbani';

  @override
  String get navSearch => 'Tafuta';

  @override
  String get navSaved => 'Zilizohifadhiwa';

  @override
  String get navProfile => 'Wasifu';

  @override
  String get heroTitle => 'Ununuzi wa Premium';

  @override
  String get heroSubtitle =>
      'Gundua mikusanyiko iliyochaguliwa kwa bei isiyoshindikana.';

  @override
  String get searchPlaceholder => 'Tafuta bidhaa, chapa, kategoria...';

  @override
  String get searchNoResults => 'Hakuna matokeo';

  @override
  String get searchTryDifferent => 'Jaribu maneno tofauti';

  @override
  String get searchOnAmazon => 'Tafuta kwenye Amazon';

  @override
  String get searchPeopleAreSearching => 'Watu wanatafuta';

  @override
  String get searchRecentSearches => 'Utafutaji wa hivi karibuni';

  @override
  String get searchClearAll => 'Futa zote';

  @override
  String get searchBrowseCategories => 'Vinjari kategoria';

  @override
  String searchResultsFor(Object query) {
    return 'Matokeo kwa \"$query\"';
  }

  @override
  String get searchAmazonResults => 'Kutoka Amazon';

  @override
  String get searchClickShopResults => 'Matokeo ya ClickShop';

  @override
  String get searchFilters => 'Vichujio';

  @override
  String get searchSortBy => 'Panga kwa';

  @override
  String get searchSortRelevance => 'Umuhimu';

  @override
  String get searchSortPriceLow => 'Bei: Chini hadi Juu';

  @override
  String get searchSortPriceHigh => 'Bei: Juu hadi Chini';

  @override
  String get searchSortNewest => 'Mpya';

  @override
  String get searchFilterPrice => 'Bei';

  @override
  String get searchFilterBrand => 'Chapa';

  @override
  String get searchFilterCategory => 'Aina';

  @override
  String get searchFilterSource => 'Chanzo';

  @override
  String get searchFilterAll => 'Zote';

  @override
  String get searchFilterClickShop => 'ClickShop';

  @override
  String get searchFilterAmazon => 'Amazon';

  @override
  String get searchFilterApply => 'Tumia Vichujio';

  @override
  String get searchFilterClear => 'Futa Vichujio';

  @override
  String get searchFilterMin => 'Bei ndogo';

  @override
  String get searchFilterMax => 'Bei kubwa';

  @override
  String get searchEmptyTitle => 'Hakuna bidhaa zinazolingana';

  @override
  String get searchEmptySubtitle =>
      'Jaribu maneno tofauti au vinjari kategoria zetu.';

  @override
  String get categoryTitle => 'Aina';

  @override
  String get categoryShopAll => 'Nunua zote';

  @override
  String get categoryShopByCategory => 'Nunua kwa aina';

  @override
  String get categoryAll => 'Zote';

  @override
  String get categorySneakers => 'Viatu';

  @override
  String get categoryFashion => 'Mitindo';

  @override
  String get categoryElectronics => 'Elektroniki';

  @override
  String get categoryAccessories => 'Vifaa';

  @override
  String get productAddToCart => 'Ongeza Kwenye Kikapu';

  @override
  String get productBuyNow => 'Nunua Sasa';

  @override
  String get productSave => 'Hifadhi';

  @override
  String get productSaved => 'Imehifadhiwa';

  @override
  String get productCompare => 'Linganisha';

  @override
  String get productInStock => 'Ipo Stokini';

  @override
  String get productLowStock => 'Stokini Kidogo';

  @override
  String get productOutOfStock => 'Imeisha Stokini';

  @override
  String get productDetails => 'Maelezo';

  @override
  String get productSpecifications => 'Vipimo';

  @override
  String get productRelated => 'Pia unaweza kupenda';

  @override
  String get productSimilar => 'Bidhaa sawa';

  @override
  String get productCheaperAlternatives => 'Badala za bei nafuu';

  @override
  String get productHigherEnd => 'Badala za juu';

  @override
  String get productComplementary => 'Zinazofaa pamoja';

  @override
  String get productReviews => 'Maoni';

  @override
  String get productNoReviews => 'Hakuna maoni bado';

  @override
  String get productOutOfStockMessage => 'Bidhaa hii haipatikani sasa.';

  @override
  String get cartTitle => 'Kikapu cha Ununuzi';

  @override
  String get cartEmpty => 'Kikapu chako ni tupu';

  @override
  String get cartEmptySubtitle => 'Ongeza bidhaa ili kuanza ununuzi.';

  @override
  String get cartSubtotal => 'Jumla ndogo';

  @override
  String get cartShipping => 'Usafirishaji';

  @override
  String get cartShippingFree => 'Bure';

  @override
  String get cartShippingOver500 =>
      'Usafirishaji bure kwa maagizo zaidi ya \$500';

  @override
  String get cartTotal => 'Jumla';

  @override
  String get cartCheckout => 'Endelea na Malipo';

  @override
  String get cartClearAll => 'Futa Kikapu';

  @override
  String get cartRemove => 'Ondoa';

  @override
  String get cartQty => 'Idadi';

  @override
  String get checkoutTitle => 'Malipo';

  @override
  String get checkoutContact => 'Taarifa za Mawasiliano';

  @override
  String get checkoutShipping => 'Anwani ya Usafirishaji';

  @override
  String get checkoutPayment => 'Njia ya Malipo';

  @override
  String get checkoutReview => 'Kagua Agizo';

  @override
  String get checkoutPlaceOrder => 'Weka Agizo';

  @override
  String get checkoutProcessing => 'Inachakata...';

  @override
  String get checkoutSuccess => 'Agizo limewekwa kwa mafanikio!';

  @override
  String get checkoutEmail => 'Barua pepe';

  @override
  String get checkoutPhone => 'Simu';

  @override
  String get checkoutFullName => 'Jina kamili';

  @override
  String get checkoutAddress => 'Anwani';

  @override
  String get checkoutCity => 'Jiji';

  @override
  String get checkoutState => 'Mkoa';

  @override
  String get checkoutZip => 'Nambari ya Posta';

  @override
  String get checkoutCountry => 'Nchi';

  @override
  String get checkoutCardNumber => 'Nambari ya Kadi';

  @override
  String get checkoutExpiry => 'Mwisho wa Muda';

  @override
  String get checkoutCVV => 'CVV';

  @override
  String get checkoutBack => 'Rudi';

  @override
  String get checkoutNext => 'Endelea';

  @override
  String get checkoutOrderSummary => 'Muhtasari wa Agizo';

  @override
  String get checkoutShippingMethod => 'Njia ya Usafirishaji';

  @override
  String get checkoutStandard => 'Usafirishaji wa Kawaida (siku 5-7)';

  @override
  String get checkoutExpress => 'Usafirishaji wa Haraka (siku 2-3)';

  @override
  String get checkoutPaymentApplePay => 'Apple Pay';

  @override
  String get checkoutPaymentCreditCard => 'Kadi ya Mkopo';

  @override
  String get checkoutPaymentPayPal => 'PayPal';

  @override
  String get authLoginTitle => 'Ingia';

  @override
  String get authLoginSubtitle => 'Fikia akaunti yako ya ClickShop';

  @override
  String get authLoginEmail => 'Barua pepe';

  @override
  String get authLoginPassword => 'Nenosiri';

  @override
  String get authLoginButton => 'INGIA';

  @override
  String get authLoginForgot => 'Umesahau Nenosiri?';

  @override
  String get authLoginGoogle => 'Endelea na Google';

  @override
  String get authLoginNoAccount => 'Huna akaunti?';

  @override
  String get authLoginSignUp => 'Jisajili';

  @override
  String get authLoginWelcomeBack => 'KARIBU TENA';

  @override
  String get authSignUpTitle => 'Fungua Akaunti';

  @override
  String get authSignUpSubtitle =>
      'Jiunge na Click Shop na ufungue ufikiaji wa premium.';

  @override
  String get authSignUpName => 'Jina Kamili';

  @override
  String get authSignUpEmail => 'Barua pepe';

  @override
  String get authSignUpPassword => 'Nenosiri';

  @override
  String get authSignUpConfirm => 'Thibitisha Nenosiri';

  @override
  String get authSignUpButton => 'FUNGUA AKAUNTI';

  @override
  String get authSignUpHasAccount => 'Tayari una akaunti?';

  @override
  String get authSignUpSignIn => 'Ingia';

  @override
  String get authSignUpCreate => 'JISAJILI';

  @override
  String get authSignUpDetails => 'Weka maelezo yako ili kuanza.';

  @override
  String get profileTitle => 'Wasifu';

  @override
  String get profileQuickAccess => 'Upatikanaji wa Haraka';

  @override
  String get profileCompare => 'Linganisha';

  @override
  String get profileSaved => 'Zilizohifadhiwa';

  @override
  String get profileAffiliate => 'Programu ya Ushirika';

  @override
  String get profileDiscover => 'Gundua';

  @override
  String get profileCollections => 'Mikusanyiko';

  @override
  String get profileGuides => 'Miongozo ya Ununuzi';

  @override
  String get profileHelpChoose => 'Nisaidie kuchagua';

  @override
  String get profileOrders => 'Maagizo';

  @override
  String get profileOwner => 'Mmiliki';

  @override
  String get profileDashboard => 'Dashibodi ya Mmiliki';

  @override
  String get profileStoreInfo => 'Taarifa za Duka';

  @override
  String get profileAbout => 'Kuhusu ClickShop';

  @override
  String get profileContact => 'Wasiliana nasi';

  @override
  String get profilePrivacy => 'Sera ya Faragha';

  @override
  String get profileTerms => 'Masharti ya Huduma';

  @override
  String get profileSignOut => 'Ondoka';

  @override
  String get profileSignIn => 'Ingia';

  @override
  String get profileSignedOut =>
      'Ingia ili kufikia akaunti, maagizo na vitu vilivyohifadhiwa.';

  @override
  String get profileGuest => 'Mgeni';

  @override
  String get profileClicks => 'Bofyo';

  @override
  String get profileSales => 'Mauzo';

  @override
  String get profileEarned => 'Iliyopatikana';

  @override
  String get savedTitle => 'Zilizohifadhiwa';

  @override
  String get savedEmpty => 'Hakuna vitu vilivyohifadhiwa';

  @override
  String get savedEmptySubtitle => 'Vitu unavyohifadhita vinatokea hapa.';

  @override
  String get savedBuyOnAmazon => 'Nunua kwenye Amazon';

  @override
  String get ordersTitle => 'Maagizo';

  @override
  String get ordersEmpty => 'Hakuna maagizo bado';

  @override
  String get ordersEmptySubtitle => 'Historia yako ya maagizo itatokea hapa.';

  @override
  String get ordersActive => 'Yanayofanya Kazi';

  @override
  String get ordersCompleted => 'Yamekamilika';

  @override
  String get ordersCancelled => 'Yamefutwa';

  @override
  String get ordersViewDetails => 'Tazama Maelezo';

  @override
  String get ordersTrack => 'Fuatilia Agizo';

  @override
  String get ordersReorder => 'Weka Tena';

  @override
  String get compareTitle => 'Linganisha Bidhaa';

  @override
  String get compareEmpty => 'Hakuna bidhaa za kulinganisha';

  @override
  String get compareEmptySubtitle => 'Ongeza hadi bidhaa 4 ili kulinganisha.';

  @override
  String get compareRemove => 'Ondoa';

  @override
  String get compareAddMore => 'Ongeza zaidi';

  @override
  String get compareIdentical => 'Zinafanana';

  @override
  String get compareDifferences => 'Tofauti';

  @override
  String get helpTitle => 'Nisaidie Kuchagua';

  @override
  String get helpSubtitle =>
      'Jibu maswali mawili na tutakupatia bidhaa sahihi.';

  @override
  String get helpWhatBuying => 'Unanunua nini?';

  @override
  String get helpBudget => 'Bajeti yako ni ngapi?';

  @override
  String get helpResults => 'Mapendekezo kwako';

  @override
  String get helpNoResults => 'Hakuna bidhaa kwa uchaguzi huu.';

  @override
  String get helpTryAgain => 'Jaribu chaguo tofauti.';

  @override
  String get helpBack => 'Rudi';

  @override
  String get helpNext => 'Endelea';

  @override
  String get helpFinish => 'Tazama matokeo';

  @override
  String get footerShop => 'Duka';

  @override
  String get footerHelp => 'Msaada';

  @override
  String get footerCompany => 'Kampuni';

  @override
  String get footerLegal => 'Kisheria';

  @override
  String get aboutTitle => 'Kuhusu ClickShop';

  @override
  String get contactTitle => 'Wasiliana Nasi';

  @override
  String get contactName => 'Jina';

  @override
  String get contactEmail => 'Barua pepe';

  @override
  String get contactSubject => 'Mada';

  @override
  String get contactMessage => 'Ujumbe';

  @override
  String get contactSend => 'Tuma Ujumbe';

  @override
  String get contactSuccess =>
      'Ujumbe umetumwa! Tutawasiliana nawo hivi karibuni.';

  @override
  String get contactError => 'Imeshindwa kutuma ujumbe. Tafadhali jaribu tena.';

  @override
  String get returnsTitle => 'Rejesha';

  @override
  String get shippingTitle => 'Usafirishaji';

  @override
  String get privacyTitle => 'Sera ya Faragha';

  @override
  String get termsTitle => 'Masharti ya Huduma';

  @override
  String get affiliateTitle => 'Programu ya Ushirika';

  @override
  String get affiliateSubtitle =>
      'Pata viwango kwa kushiriki bidhaa za ClickShop.';

  @override
  String get affiliateSignUp => 'Jiunge Sasa';

  @override
  String get affiliateDashboard => 'Dashibodi Yako';

  @override
  String get affiliatePromoCode => 'Msimbo wa Promosheni';

  @override
  String get affiliateLink => 'Kiungo cha Riferi';

  @override
  String get affiliateStats => 'Takwimu Zako';

  @override
  String get affiliateCommissions => 'Kodi';

  @override
  String get errorNetwork => 'Hitilafu ya mtandao. Angalia muunganisho wako.';

  @override
  String get errorGeneric =>
      'Kuna kitu kimeenda vibaya. Tafadhali jaribu tena.';

  @override
  String get errorUnauthorized => 'Tafadhali tena.';

  @override
  String get errorNotFound => 'Ukurasa haujapatikana';

  @override
  String get loadingDefault => 'Inapakia...';

  @override
  String get retry => 'Jaribu tena';

  @override
  String get ok => 'Sawa';

  @override
  String get cancel => 'Ghairi';

  @override
  String get confirm => 'Thibitisha';

  @override
  String get close => 'Funga';

  @override
  String get back => 'Rudi';

  @override
  String get next => 'Endelea';

  @override
  String get done => 'Imekamilika';

  @override
  String get save => 'Hifadhi';

  @override
  String get delete => 'Futa';

  @override
  String get edit => 'Hariri';

  @override
  String get share => 'Shiriki';

  @override
  String get viewAll => 'Tazama zote';

  @override
  String get seeMore => 'Tazama zaidi';

  @override
  String get seeLess => 'Tazama kidogo';

  @override
  String get ownerTitle => 'Dashibodi ya Mmiliki';

  @override
  String get ownerRevenue => 'Mapato';

  @override
  String get ownerOrders => 'Maagizo';

  @override
  String get ownerProducts => 'Bidhaa';

  @override
  String get ownerUsers => 'Watumiaji';

  @override
  String get ownerLowStock => 'Stokini kidogo';

  @override
  String get ownerSalesToday => 'Mauzo ya leo';

  @override
  String get ownerAnalytics => 'Tabia ya Wateja';

  @override
  String get ownerInbox => 'Kikasha cha Mawasiliano';

  @override
  String get ownerAudit => 'Ufuatiliaji';

  @override
  String ownerUnread(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zisomaswa',
      zero: 'Hakuna',
    );
    return '$_temp0';
  }

  @override
  String get affiliateDisclosure =>
      'Kama mshirika, ClickShop inaweza kupata komisheni kutoka kwa viungo washirika.';

  @override
  String get freeShipping => 'Usafirishaji bure kwa maagizo zaidi ya \$500';

  @override
  String get newsletterTitle => 'Kaa na sisi';

  @override
  String get newsletterSubtitle => 'Pata taarifa kuhusu bidhaa mpya na ofa.';

  @override
  String get newsletterPlaceholder => 'Weka barua pepe yako';

  @override
  String get newsletterButton => 'Jiandikishe';

  @override
  String get onboardingTitle => 'Karibu ClickShop';

  @override
  String get onboardingSubtitle => 'Mitindo premium, viatu na elektroniki';

  @override
  String get onboardingGetStarted => 'Anza';

  @override
  String get onboardingSkip => 'Ruka';

  @override
  String get signOutConfirmTitle => 'Ondoka?';

  @override
  String get signOutConfirmMessage =>
      'Utaondoka kwenye akaunti yako ya ClickShop.';

  @override
  String get clearCartTitle => 'Futa kikapu?';

  @override
  String get clearCartMessage => 'Vitu vyote vitaondolewa kwenye kikapu chako.';
}
