import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../domain/entities/product.dart';
import '../data/recent_views_store.dart';
import '../data/search_history_store.dart';

final recentViewsProvider =
    AsyncNotifierProvider<RecentViewsNotifier, List<Product>>(
        RecentViewsNotifier.new);

class RecentViewsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() {
    return sl<RecentViewsStore>().load();
  }

  Future<void> record(Product product) async {
    final store = sl<RecentViewsStore>();
    await store.record(product);
    state = AsyncData(await store.load());
  }

  Future<void> clear() async {
    final store = sl<RecentViewsStore>();
    await store.clear();
    state = const AsyncData(<Product>[]);
  }
}

/// Local search-history chips (persisted) — shown alongside the server's
/// popular searches so an empty search surface is both personal and honest.
final searchHistoryProvider =
    NotifierProvider<SearchHistoryNotifier, List<String>>(
        SearchHistoryNotifier.new);

class SearchHistoryNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return sl<SearchHistoryStore>().load() ?? const [];
  }

  void add(String query) {
    final store = sl<SearchHistoryStore>();
    final next = store.add(query);
    state = next;
  }

  void remove(String query) {
    final store = sl<SearchHistoryStore>();
    state = store.remove(query);
  }

  void clear() {
    final store = sl<SearchHistoryStore>();
    state = store.clear();
  }
}