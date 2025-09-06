import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'repo.dart';
import 'models.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _imageIndex = 0;
  String? _variant;

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(shopRepositoryProvider);
    return FutureBuilder<Product>(
      future: repo.product(widget.productId),
      builder: (context, snap) {
        if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final p = snap.data!;
        final images = p.images;
        return Scaffold(
          appBar: AppBar(title: Text(p.name)),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                GlassCard(
                  height: 220,
                  child: Stack(children: [
                    Center(child: Icon(Icons.image, size: 80)),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (i) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: GestureDetector(
                                onTap: () => setState(() => _imageIndex = i),
                                child: CircleAvatar(radius: 4, backgroundColor: i == _imageIndex ? Colors.white : Colors.white24),
                              ),
                            )),
                      ),
                    )
                  ]),
                ),
                const SizedBox(height: 12),
                Row(children: [Text('£${p.price}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)), const Spacer(), Text('Stock: ${p.stock}')]),
                const SizedBox(height: 8),
                if (p.variants.isNotEmpty)
                  Wrap(spacing: 8, children: p.variants.map((v) => ChoiceChip(label: Text(v.option), selected: _variant == v.option, onSelected: (_) => setState(() => _variant = v.option))).toList()),
                const SizedBox(height: 12),
                Text(p.description.isEmpty ? 'Clean minimal product in UK market style.' : p.description),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: AppButtons.primary(label: 'Add to Cart', icon: Icons.add_shopping_cart, onPressed: () async { await repo.addToCart(p.id, 1); if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart'))); })),
                  const SizedBox(width: 12),
                  Expanded(child: AppButtons.primary(label: 'Buy Now', icon: Icons.flash_on, onPressed: () async { await repo.addToCart(p.id, 1); if(!mounted) return; context.go('/shop/checkout'); }))
                ]),
                const SizedBox(height: 8),
                TextButton.icon(onPressed: () async { await repo.addWishlist(p.id); if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to wishlist'))); }, icon: const Icon(Icons.favorite_border), label: const Text('Add to Wishlist')),
              ],
            ),
          ),
        );
      },
    );
  }
}
