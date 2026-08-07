import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'firebase_options.dart';
import 'core/services/service_locator.dart';
import 'domain/usecases/affiliate_usecase.dart';
import 'app/routes.dart';
import 'config/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    MobileAds.instance.initialize();
  }

  await initServiceLocator();
  await _captureReferralFromLink();

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ClickShop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 0.85,
        maxScaleFactor: 1.3,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
