import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../domain/entities/amazon_product.dart';
import '../data/saved_store.dart';

final savedProvider =
    AsyncNotifierProvider<SavedNotifier, List<AmazonProduct>>(
        SavedNotifier.new);

class SavedNotifier extends AsyncNotifier<List<AmazonProduct>> {
  @override
  Future<List<AmazonProduct>> build() {
    return sl<SavedStore>().load();
  }

  bool isSaved(String asin) {
    final current = state.asData?.value ?? const <AmazonProduct>[];
    return current.any((p) => p.asin == asin);
  }

  Future<void> toggle(AmazonProduct product) async {
    final current = state.asData?.value ?? const <AmazonProduct>[];
    final exists = current.any((p) => p.asin == product.asin);
    final next = exists
        ? current.where((p) => p.asin != product.asin).toList()
        : [product, ...current];
    state = AsyncData(next);
    await sl<SavedStore>().persist(next);
  }

  Future<void> clearAll() async {
    state = AsyncData(const <AmazonProduct>[]);
    await sl<SavedStore>().persist(const []);
  }
}