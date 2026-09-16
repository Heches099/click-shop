import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';
import 'core/services/service_locator.dart';
import 'core/services/seo/seo_service.dart';
import 'domain/usecases/affiliate_usecase.dart';
import 'app/routes.dart';
import 'config/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'presentation/settings/providers/locale_provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SEO: use clean path URLs (no /#/ fragment) so crawlers and humans share
  // the exact same URLs. Search engines ignore hash-based routes entirely.
  usePathUrlStrategy();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    MobileAds.instance.initialize();
  }

  await initServiceLocator();
  await _captureReferralFromLink();

  // E-E-A-T: inject WebSite + Organization structured data and set a default
  // page title/description so crawlers that skip JS still see a complete page.
  SeoService.instance.injectSiteSchema();
  SeoService.instance.setPageMeta(
    title: 'ClickShop — Premium Fashion, Sneakers & Electronics',
    description:
        'ClickShop is your premium online store for fashion, sneakers and '
        'electronics at the best prices with fast delivery and real reviews.',
    canonicalPath: '/',
  );

  runApp(const ProviderScope(child: MyApp()));
}

/// Captures an affiliate `?ref=CODE` from the URL (web) or deep link
/// (mobile), attributes it to the current session and counts the click.
Future<void> _captureReferralFromLink() async {
  final useCase = sl<AffiliateUseCase>();
  final query = Uri.base.queryParameters;
  final ref = query['ref'] ?? query['affiliate'];
  if (ref == null || ref.trim().isEmpty) return;
  await useCase.trackIncomingRef(ref);
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Restore the visitor's saved language once Hive settings are available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(localeProvider.notifier).restore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'ClickShop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightForLocale(locale.languageCode),
      darkTheme: AppTheme.darkForLocale(locale.languageCode),
      locale: locale,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      routerConfig: router,
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 0.85,
        maxScaleFactor: 1.3,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
