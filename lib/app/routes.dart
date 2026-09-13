import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../domain/entities/product.dart';
import '../presentation/affiliate/screens/affiliate_portal_screen.dart';
import '../presentation/auth/screens/login_screen.dart';
import '../presentation/auth/screens/signup_screen.dart';
import '../presentation/categories/screens/category_detail_screen.dart';
import '../presentation/core/screens/not_found_screen.dart';
import '../presentation/product/screens/product_detail_screen.dart';
import '../presentation/search/screens/search_screen.dart';
import '../presentation/core/screens/main_scaffold.dart';
import '../presentation/onboarding/screens/onboarding_screen.dart';

final router = GoRouter(
  initialLocation: '/onboarding',
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