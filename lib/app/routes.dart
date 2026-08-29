import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../domain/entities/product.dart';
import '../presentation/affiliate/screens/affiliate_portal_screen.dart';
import '../presentation/auth/screens/login_screen.dart';
import '../presentation/auth/screens/signup_screen.dart';
import '../presentation/categories/screens/category_detail_screen.dart';
import '../presentation/product/screens/product_detail_screen.dart';
import '../presentation/orders/screens/order_list_screen.dart';
import '../presentation/checkout/screens/checkout_screen.dart';
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
      path: '/category/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? 'all';
        return CategoryDetailScreen(slug: slug);
      },
    ),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) => _productDetail(state),
    ),
    GoRoute(
      path: '/products/:id',
      builder: (context, state) => _productDetail(state),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrderListScreen(),
    ),
    GoRoute(
      path: '/affiliate',
      builder: (context, state) => const AffiliatePortalScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
  ],
);

/// Builds a [ProductDetailScreen] from either the in-memory [Product] passed
/// via `state.extra` (fast, animated navigation) or a lightweight placeholder
/// that the screen hydrates by fetching the product from the repository when
/// the page is deep-linked / refreshed directly (SEO friendly clean URLs).
Widget _productDetail(GoRouterState state) {
  final extra = state.extra;
  final product = extra is Product
      ? extra
      : Product(
          id: state.pathParameters['id'] ?? 'unknown',
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
