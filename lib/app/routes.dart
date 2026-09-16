import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../core/services/analytics/analytics_service.dart';
import '../core/services/service_locator.dart';
import '../domain/entities/product.dart';
import '../presentation/affiliate/screens/affiliate_portal_screen.dart';
import '../presentation/auth/screens/login_screen.dart';
import '../presentation/auth/screens/signup_screen.dart';
import '../presentation/categories/screens/category_detail_screen.dart';
import '../presentation/checkout/screens/checkout_screen.dart';
import '../presentation/core/screens/not_found_screen.dart';
import '../presentation/orders/screens/order_list_screen.dart';
import '../presentation/product/screens/product_detail_screen.dart';
import '../presentation/search/screens/search_screen.dart';
import '../presentation/core/screens/main_scaffold.dart';
import '../presentation/onboarding/screens/onboarding_screen.dart';

final router = GoRouter(
  initialLocation: '/onboarding',
  observers: [LazyAnalyticsObserver()],
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const WinningOnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScaffold(),
    ),
    GoRoute(
      path: '/product/:slug',
      builder: (context, state) => _productDetail(state),
    ),
    GoRoute(
      path: '/category/:slug',
      builder: (context, state) =>
          CategoryDetailScreen(slug: state.pathParameters['slug'] ?? 'all'),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => SearchScreen(
        initialQuery: state.uri.queryParameters['q'],
      ),
    ),
    GoRoute(
      path: '/affiliate',
      builder: (context, state) => const AffiliatePortalScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrderListScreen(),
    ),
    // Legacy `/products/:id` product URLs — redirected to the canonical slug
    // URL when the product is resolved (kept as a route so deep links survive).
    GoRoute(
      path: '/products/:id',
      builder: (context, state) => _productDetail(state),
    ),
    GoRoute(
      path: '/:pathMatch(.*)*',
      builder: (context, state) => const NotFoundScreen(),
    ),
  ],
);

/// Builds a [ProductDetailScreen] from either the in-memory [Product] passed
/// via `state.extra` (fast, animated navigation) or a lightweight placeholder
/// that the screen hydrates by resolving the slug/id from the repository when
/// the page is deep-linked / refreshed directly (SEO friendly clean URLs).
Widget _productDetail(GoRouterState state) {
  final extra = state.extra;
  final product = extra is Product
      ? extra
      : Product(
          id: state.pathParameters['id'] ?? state.pathParameters['slug'] ?? 'unknown',
          name: 'Product',
          brand: '',
          description: '',
          price: 0,
          images: const [],
          rating: 0,
          reviewCount: 0,
          category: '',
          stock: 0,
        );
  return ProductDetailScreen(
    product: product,
    hydrated: extra is! Product,
  );
}

/// Forwards navigation events to Firebase Analytics, resolving the service
/// lazily on the first event so importing this file never requires the service
/// locator (the boot smoke test and tooling import routes.dart directly).
/// If analytics is unavailable (e.g. DI not yet initialised) events are
/// silently dropped — analytics must never interrupt navigation.
class LazyAnalyticsObserver extends NavigatorObserver {
  AnalyticsService? _analytics;
  bool _available = true;

  AnalyticsService? get _service {
    if (!_available) return null;
    return _analytics ??= _tryResolve();
  }

  AnalyticsService? _tryResolve() {
    try {
      return sl<AnalyticsService>();
    } catch (_) {
      _available = false;
      return null;
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _service?.observer.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _service?.observer.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _service?.observer.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _service?.observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}