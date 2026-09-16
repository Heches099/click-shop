import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../domain/entities/product.dart';
import '../data/compare_store.dart';

/// The Compare shortlist. Persisted locally (Hive) — comparing is a personal
/// tool, not a network feature. Capacity is deliberately small (4) so the
/// comparison stays readable instead of becoming a spreadsheet.
final compareProvider =
    AsyncNotifierProvider<CompareNotifier, List<Product>>(CompareNotifier.new);

class CompareNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() {
    return sl<CompareStore>().load();
  }

  List<Product> get _current => state.asData?.value ?? const <Product>[];

  bool isInCompare(String productId) =>
      _current.any((p) => p.id == productId);

  bool isFull() => _current.length >= CompareStore.maxItems;

  Future<bool> toggle(Product product) async {
    final exists = _current.any((p) => p.id == product.id);
    if (exists) {
      state = AsyncData(
        _current.where((p) => p.id != product.id).toList(),
      );
      await sl<CompareStore>().persist(state.asData!.value);
      return false;
    }
    if (isFull()) return false;
    state = AsyncData([product, ..._current]);
    await sl<CompareStore>().persist(state.asData!.value);
    return true;
  }

  Future<void> remove(String productId) async {
    state = AsyncData(_current.where((p) => p.id != productId).toList());
    await sl<CompareStore>().persist(state.asData!.value);
  }

  Future<void> clear() async {
    state = const AsyncData(<Product>[]);
    await sl<CompareStore>().persist(const []);
  }
}