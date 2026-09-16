import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../domain/entities/admin_analytics.dart';
import '../../../domain/usecases/product_usecase.dart';

final relatedUseCase = Provider<ProductUseCase>((ref) {
  return sl<ProductUseCase>();
});

/// Honest "need more options" rail: similar, cheaper, higher-end and
/// complementary picks come from `GET /products/{id}/related`.
final relatedProductsProvider =
    FutureProvider.autoDispose.family<RelatedProducts, String>(
        (ref, productId) async {
  return ref.watch(relatedUseCase).getRelated(productId);
});