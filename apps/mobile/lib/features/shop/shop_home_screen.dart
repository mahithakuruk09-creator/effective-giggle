import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'repo.dart';
import 'models.dart';
import 'widgets.dart';
import 'product_list_screen.dart';
import 'cart_screen.dart';
import 'wishlist_screen.dart';
import '../../widgets/pinto_coin_badge.dart';

final shopRepositoryProvider = Provider<ShopRepository>((ref) => ShopRepositoryHttp());
final productsProvider = FutureProvider.family<List<Product>, String?>((ref, category) => ref.read(shopRepositoryProvider).products(category: category));
final rewardsAccountProvider = FutureProvider<RewardAccount>((ref) => ref.read(shopRepositoryProvider).rewards());

class ShopHomeScreen extends ConsumerWidget {
  const ShopHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = const ['Apparel', 'Gadgets', 'Lifestyle', 'Digital'];
    final rewards = ref.watch(rewardsAccountProvider).valueOrNull?.balance ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          const Padding(padding: EdgeInsets.only(right: 8), child: SizedBox(width: 28, child: Center(child: PintoCoinBadge()))),
          Center(child: Text('Pintos: $rewards', style: const TextStyle(fontWeight: FontWeight.w600))),
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen())), icon: const Icon(Icons.favorite_border)),
          IconButton(onPressed: () => Navigator.pushNamed(context, '/shop/orders'), icon: const Icon(Icons.history)),
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())), icon: const Icon(Icons.shopping_bag_outlined)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search products', filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
          const SizedBox(height: 12),
          SizedBox(
            height: 96,
            child: GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              children: [
                for (final c in categories)
                  InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListScreen(category: c))), child: GlassCard(child: Center(child: Text(c))))
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer(builder: (context, ref, _) {
              final ps = ref.watch(productsProvider(null));
              return ps.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: TextButton(onPressed: () => ref.refresh(productsProvider(null)), child: const Text('Retry'))),
                data: (list) => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.78),
                  itemCount: list.length,
                  itemBuilder: (c, i) => ProductCard(
                    product: list[i],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: list[i].id))),
                    onAddToCart: () async {
                      await ref.read(shopRepositoryProvider).addToCart(list[i].id, 1);
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                    },
                  ),
                ),
              );
            }),
          ),
        ]),
      ),
    );
  }
}
