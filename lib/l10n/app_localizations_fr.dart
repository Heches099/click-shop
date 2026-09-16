// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'ClickShop';

  @override
  String get appTagline => 'Des vrais produits. De vrais prix. Pas de tricks.';

  @override
  String get appSubtitle =>
      'Mode premium, sneakers et electronique aux meilleurs prix.';

  @override
  String get navHome => 'Accueil';

  @override
  String get navSearch => 'Recherche';

  @override
  String get navSaved => 'Sauvegardes';

  @override
  String get navProfile => 'Profil';

  @override
  String get heroTitle => 'Shopping Premium';

  @override
  String get heroSubtitle =>
      'Decouvrez des collections selectionnees a des prix imbattables.';

  @override
  String get searchPlaceholder =>
      'Rechercher des produits, marques, categories...';

  @override
  String get searchNoResults => 'Aucun resultat';

  @override
  String get searchTryDifferent => 'Essayez un autre terme';

  @override
  String get searchOnAmazon => 'Rechercher sur Amazon';

  @override
  String get searchPeopleAreSearching => 'Les gens recherchent';

  @override
  String get searchRecentSearches => 'Recherches recentes';

  @override
  String get searchClearAll => 'Tout effacer';

  @override
  String get searchBrowseCategories => 'Parcourir les categories';

  @override
  String searchResultsFor(Object query) {
    return 'Resultats pour \"$query\"';
  }

  @override
  String get searchAmazonResults => 'Depuis Amazon';

  @override
  String get searchClickShopResults => 'Resultats ClickShop';

  @override
  String get searchFilters => 'Filtres';

  @override
  String get searchSortBy => 'Trier par';

  @override
  String get searchSortRelevance => 'Pertinence';

  @override
  String get searchSortPriceLow => 'Prix : croissant';

  @override
  String get searchSortPriceHigh => 'Prix : decroissant';

  @override
  String get searchSortNewest => 'Plus recent';

  @override
  String get searchFilterPrice => 'Prix';

  @override
  String get searchFilterBrand => 'Marque';

  @override
  String get searchFilterCategory => 'Categorie';

  @override
  String get searchFilterSource => 'Source';

  @override
  String get searchFilterAll => 'Tout';

  @override
  String get searchFilterClickShop => 'ClickShop';

  @override
  String get searchFilterAmazon => 'Amazon';

  @override
  String get searchFilterApply => 'Appliquer';

  @override
  String get searchFilterClear => 'Effacer les filtres';

  @override
  String get searchFilterMin => 'Prix min';

  @override
  String get searchFilterMax => 'Prix max';

  @override
  String get searchEmptyTitle => 'Aucun produit ne correspond';

  @override
  String get searchEmptySubtitle =>
      'Essayez d\'autres mots-cles ou parcourez nos categories.';

  @override
  String get categoryTitle => 'Categories';

  @override
  String get categoryShopAll => 'Tout acheter';

  @override
  String get categoryShopByCategory => 'Acheter par categorie';

  @override
  String get categoryAll => 'Tout';

  @override
  String get categorySneakers => 'Sneakers';

  @override
  String get categoryFashion => 'Mode';

  @override
  String get categoryElectronics => 'Electronique';

  @override
  String get categoryAccessories => 'Accessoires';

  @override
  String get productAddToCart => 'Ajouter au panier';

  @override
  String get productBuyNow => 'Acheter maintenant';

  @override
  String get productSave => 'Sauvegarder';

  @override
  String get productSaved => 'Sauvegarde';

  @override
  String get productCompare => 'Comparer';

  @override
  String get productInStock => 'En stock';

  @override
  String get productLowStock => 'Stock faible';

  @override
  String get productOutOfStock => 'Rupture de stock';

  @override
  String get productDetails => 'Details';

  @override
  String get productSpecifications => 'Specifications';

  @override
  String get productRelated => 'Vous aimerez aussi';

  @override
  String get productSimilar => 'Produits similaires';

  @override
  String get productCheaperAlternatives => 'Alternatives moins cheres';

  @override
  String get productHigherEnd => 'Alternatives haut de gamme';

  @override
  String get productComplementary => 'Complementaires';

  @override
  String get productReviews => 'Avis';

  @override
  String get productNoReviews => 'Pas encore d\'avis';

  @override
  String get productOutOfStockMessage =>
      'Ce produit est actuellement indisponible.';

  @override
  String get cartTitle => 'Panier';

  @override
  String get cartEmpty => 'Votre panier est vide';

  @override
  String get cartEmptySubtitle => 'Ajoutez des articles pour commencer.';

  @override
  String get cartSubtotal => 'Sous-total';

  @override
  String get cartShipping => 'Livraison';

  @override
  String get cartShippingFree => 'Gratuite';

  @override
  String get cartShippingOver500 =>
      'Livraison gratuite pour les commandes de plus de 500 \$';

  @override
  String get cartTotal => 'Total';

  @override
  String get cartCheckout => 'Passer a la caisse';

  @override
  String get cartClearAll => 'Vider le panier';

  @override
  String get cartRemove => 'Supprimer';

  @override
  String get cartQty => 'Qté';

  @override
  String get checkoutTitle => 'Paiement';

  @override
  String get checkoutContact => 'Informations de contact';

  @override
  String get checkoutShipping => 'Adresse de livraison';

  @override
  String get checkoutPayment => 'Moyen de paiement';

  @override
  String get checkoutReview => 'Verifier la commande';

  @override
  String get checkoutPlaceOrder => 'Passer la commande';

  @override
  String get checkoutProcessing => 'Traitement...';

  @override
  String get checkoutSuccess => 'Commande passee avec succes !';

  @override
  String get checkoutEmail => 'E-mail';

  @override
  String get checkoutPhone => 'Telephone';

  @override
  String get checkoutFullName => 'Nom complet';

  @override
  String get checkoutAddress => 'Adresse';

  @override
  String get checkoutCity => 'Ville';

  @override
  String get checkoutState => 'Region';

  @override
  String get checkoutZip => 'Code postal';

  @override
  String get checkoutCountry => 'Pays';

  @override
  String get checkoutCardNumber => 'Numero de carte';

  @override
  String get checkoutExpiry => 'Date d\'expiration';

  @override
  String get checkoutCVV => 'CVV';

  @override
  String get checkoutBack => 'Retour';

  @override
  String get checkoutNext => 'Suivant';

  @override
  String get checkoutOrderSummary => 'Resume de la commande';

  @override
  String get checkoutShippingMethod => 'Mode de livraison';

  @override
  String get checkoutStandard => 'Livraison standard (5-7 jours)';

  @override
  String get checkoutExpress => 'Livraison express (2-3 jours)';

  @override
  String get checkoutPaymentApplePay => 'Apple Pay';

  @override
  String get checkoutPaymentCreditCard => 'Carte bancaire';

  @override
  String get checkoutPaymentPayPal => 'PayPal';

  @override
  String get authLoginTitle => 'Connexion';

  @override
  String get authLoginSubtitle => 'Accedez a votre compte ClickShop';

  @override
  String get authLoginEmail => 'E-mail';

  @override
  String get authLoginPassword => 'Mot de passe';

  @override
  String get authLoginButton => 'SE CONNECTER';

  @override
  String get authLoginForgot => 'Mot de passe oublie ?';

  @override
  String get authLoginGoogle => 'Continuer avec Google';

  @override
  String get authLoginNoAccount => 'Pas encore de compte ?';

  @override
  String get authLoginSignUp => 'S\'inscrire';

  @override
  String get authLoginWelcomeBack => 'BIENVENUE';

  @override
  String get authSignUpTitle => 'Creer un compte';

  @override
  String get authSignUpSubtitle =>
      'Rejoignez Click Shop et accedez au premium.';

  @override
  String get authSignUpName => 'Nom complet';

  @override
  String get authSignUpEmail => 'E-mail';

  @override
  String get authSignUpPassword => 'Mot de passe';

  @override
  String get authSignUpConfirm => 'Confirmer le mot de passe';

  @override
  String get authSignUpButton => 'CREER UN COMPTE';

  @override
  String get authSignUpHasAccount => 'Deja un compte ?';

  @override
  String get authSignUpSignIn => 'Se connecter';

  @override
  String get authSignUpCreate => 'S\'INSCRIRE';

  @override
  String get authSignUpDetails => 'Entrez vos informations pour commencer.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileQuickAccess => 'Acces rapide';

  @override
  String get profileCompare => 'Comparer';

  @override
  String get profileSaved => 'Sauvegardes';

  @override
  String get profileAffiliate => 'Programme d\'affiliation';

  @override
  String get profileDiscover => 'Decouvrir';

  @override
  String get profileCollections => 'Collections';

  @override
  String get profileGuides => 'Guides d\'achat';

  @override
  String get profileHelpChoose => 'Aidez-moi a choisir';

  @override
  String get profileOrders => 'Commandes';

  @override
  String get profileOwner => 'Proprietaire';

  @override
  String get profileDashboard => 'Tableau de bord';

  @override
  String get profileStoreInfo => 'Info boutique';

  @override
  String get profileAbout => 'A propos de ClickShop';

  @override
  String get profileContact => 'Contactez-nous';

  @override
  String get profilePrivacy => 'Politique de confidentialite';

  @override
  String get profileTerms => 'Conditions d\'utilisation';

  @override
  String get profileSignOut => 'Deconnexion';

  @override
  String get profileSignIn => 'Se connecter';

  @override
  String get profileSignedOut =>
      'Connectez-vous pour acceder a votre compte et vos commandes.';

  @override
  String get profileGuest => 'Invite';

  @override
  String get profileClicks => 'Clics';

  @override
  String get profileSales => 'Ventes';

  @override
  String get profileEarned => 'Gagne';

  @override
  String get savedTitle => 'Sauvegardes';

  @override
  String get savedEmpty => 'Aucun article sauvegarde';

  @override
  String get savedEmptySubtitle => 'Les articles sauvegardes apparaitront ici.';

  @override
  String get savedBuyOnAmazon => 'Acheter sur Amazon';

  @override
  String get ordersTitle => 'Commandes';

  @override
  String get ordersEmpty => 'Aucune commande';

  @override
  String get ordersEmptySubtitle => 'Vos commandes apparaitront ici.';

  @override
  String get ordersActive => 'En cours';

  @override
  String get ordersCompleted => 'Terminees';

  @override
  String get ordersCancelled => 'Annulees';

  @override
  String get ordersViewDetails => 'Voir les details';

  @override
  String get ordersTrack => 'Suivre la commande';

  @override
  String get ordersReorder => 'Recommander';

  @override
  String get compareTitle => 'Comparer les produits';

  @override
  String get compareEmpty => 'Aucun produit a comparer';

  @override
  String get compareEmptySubtitle =>
      'Ajoutez jusqu\'a 4 produits pour comparer.';

  @override
  String get compareRemove => 'Supprimer';

  @override
  String get compareAddMore => 'Ajouter';

  @override
  String get compareIdentical => 'Identiques';

  @override
  String get compareDifferences => 'Differences';

  @override
  String get helpTitle => 'Aidez-moi a choisir';

  @override
  String get helpSubtitle =>
      'Repondez a deux questions et nous vous trouverons le bon produit.';

  @override
  String get helpWhatBuying => 'Que recherchez-vous ?';

  @override
  String get helpBudget => 'Quel est votre budget ?';

  @override
  String get helpResults => 'Recommandations pour vous';

  @override
  String get helpNoResults => 'Aucun produit pour cette selection.';

  @override
  String get helpTryAgain => 'Essayez d\'autres options.';

  @override
  String get helpBack => 'Retour';

  @override
  String get helpNext => 'Suivant';

  @override
  String get helpFinish => 'Voir les resultats';

  @override
  String get footerShop => 'Boutique';

  @override
  String get footerHelp => 'Aide';

  @override
  String get footerCompany => 'Entreprise';

  @override
  String get footerLegal => 'Mentions legales';

  @override
  String get aboutTitle => 'A propos de ClickShop';

  @override
  String get contactTitle => 'Contactez-nous';

  @override
  String get contactName => 'Nom';

  @override
  String get contactEmail => 'E-mail';

  @override
  String get contactSubject => 'Sujet';

  @override
  String get contactMessage => 'Message';

  @override
  String get contactSend => 'Envoyer';

  @override
  String get contactSuccess => 'Message envoye ! Nous vous repondrons bientot.';

  @override
  String get contactError => 'Echec de l\'envoi. Reessayez.';

  @override
  String get returnsTitle => 'Retours';

  @override
  String get shippingTitle => 'Livraison';

  @override
  String get privacyTitle => 'Politique de confidentialite';

  @override
  String get termsTitle => 'Conditions d\'utilisation';

  @override
  String get affiliateTitle => 'Programme d\'affiliation';

  @override
  String get affiliateSubtitle =>
      'Gagnez des commissions en partageant les produits ClickShop.';

  @override
  String get affiliateSignUp => 'Rejoindre maintenant';

  @override
  String get affiliateDashboard => 'Votre tableau de bord';

  @override
  String get affiliatePromoCode => 'Code promo';

  @override
  String get affiliateLink => 'Lien de parrainage';

  @override
  String get affiliateStats => 'Vos statistiques';

  @override
  String get affiliateCommissions => 'Commissions';

  @override
  String get errorNetwork => 'Erreur reseau. Verifiez votre connexion.';

  @override
  String get errorGeneric => 'Une erreur s\'est produite. Reessayez.';

  @override
  String get errorUnauthorized => 'Veuillez vous reconnecter.';

  @override
  String get errorNotFound => 'Page non trouvee';

  @override
  String get loadingDefault => 'Chargement...';

  @override
  String get retry => 'Reessayer';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get close => 'Fermer';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get done => 'Terminer';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get share => 'Partager';

  @override
  String get viewAll => 'Tout voir';

  @override
  String get seeMore => 'Voir plus';

  @override
  String get seeLess => 'Voir moins';

  @override
  String get ownerTitle => 'Tableau de bord proprietaire';

  @override
  String get ownerRevenue => 'Revenu';

  @override
  String get ownerOrders => 'Commandes';

  @override
  String get ownerProducts => 'Produits';

  @override
  String get ownerUsers => 'Utilisateurs';

  @override
  String get ownerLowStock => 'Stock faible';

  @override
  String get ownerSalesToday => 'Ventes du jour';

  @override
  String get ownerAnalytics => 'Comportement acheteurs';

  @override
  String get ownerInbox => 'Boite de reception';

  @override
  String get ownerAudit => 'Journal d\'audit';

  @override
  String ownerUnread(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count non lus',
      zero: 'Aucun non lu',
    );
    return '$_temp0';
  }

  @override
  String get affiliateDisclosure =>
      'En tant qu\'affilie, ClickShop peut gagner une commission via les liens partenaires.';

  @override
  String get freeShipping =>
      'Livraison gratuite pour les commandes de plus de 500 \$';

  @override
  String get newsletterTitle => 'Restez informe';

  @override
  String get newsletterSubtitle => 'Recevez les dernieres nouvelles et offres.';

  @override
  String get newsletterPlaceholder => 'Votre e-mail';

  @override
  String get newsletterButton => 'S\'abonner';

  @override
  String get onboardingTitle => 'Bienvenue sur ClickShop';

  @override
  String get onboardingSubtitle => 'Mode premium, sneakers et electronique';

  @override
  String get onboardingGetStarted => 'Commencer';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get signOutConfirmTitle => 'Se deconnecter ?';

  @override
  String get signOutConfirmMessage =>
      'Vous serez deconnecte de votre compte ClickShop.';

  @override
  String get clearCartTitle => 'Vider le panier ?';

  @override
  String get clearCartMessage =>
      'Tous les articles seront supprimes du panier.';
}
