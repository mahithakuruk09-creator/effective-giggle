import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'repo.dart';
import 'models.dart';
import 'widgets.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends ConsumerWidget {
  final String category;
  const ProductListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(shopRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: FutureBuilder<List<Product>>(
        future: repo.products(category: category),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.78),
              itemCount: list.length,
              itemBuilder: (c, i) => ProductCard(
                product: list[i],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: list[i].id))),
                onAddToCart: () async {
                  await repo.addToCart(list[i].id, 1);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

