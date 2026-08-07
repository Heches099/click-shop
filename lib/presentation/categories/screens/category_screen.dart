import '../../core/widgets/smart_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/category.dart';

// Assuming categoriesProvider is defined somewhere or dummy it
final categoriesProvider = Provider<AsyncValue<List<CategoryEntity>>>((ref) => const AsyncValue.data([]));

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: categoriesAsync.when(
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) => CategoryTile(category: list[i]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final CategoryEntity category;
  const CategoryTile({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(category.name),
      leading: category.image != null
          ? SmartImage(
              imagePath: category.image!,
              width: 40,
              height: 40,
              borderRadius: BorderRadius.circular(8),
            )
          : const Icon(Icons.category),
    );
  }
}
