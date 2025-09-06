import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'repo.dart';
import 'models.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(shopRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: FutureBuilder<List<String>>(
        future: repo.wishlist(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final ids = snap.data!;
          if (ids.isEmpty) return const Center(child: Text('Your wishlist is empty.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ids.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => FutureBuilder<Product>(
              future: repo.product(ids[i]),
              builder: (context, p) {
                if (!p.hasData) return const SizedBox.shrink();
                final prod = p.data!;
                return GlassCard(
                  child: ListTile(
                    leading: const Icon(Icons.image),
                    title: Text(prod.name),
                    subtitle: Text('£${prod.price}'),
                    trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async { await repo.removeWishlist(prod.id); (context as Element).reassemble(); }),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: prod.id))),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

