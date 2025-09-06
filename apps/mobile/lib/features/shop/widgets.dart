import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_theme.dart';
import 'models.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  const ProductCard({super.key, required this.product, required this.onTap, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Center(child: _imageOrShimmer())),
          const SizedBox(height: 6),
          Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(children: [Text('£${product.price}'), const Spacer(), AppButtons.primary(label: 'Add', onPressed: onAddToCart, icon: Icons.add_shopping_cart)])
        ]),
      ),
    );
  }
}

  Widget _imageOrShimmer(){
    // Until real assets are wired, show shimmer placeholder
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.08),
      highlightColor: Colors.white.withOpacity(0.18),
      child: Container(
        width: 80,
        height: 60,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

class CartItemTile extends StatelessWidget {
  final Product product;
  final CartItem item;
  final VoidCallback onInc;
  final VoidCallback onDec;
  const CartItemTile({super.key, required this.product, required this.item, required this.onInc, required this.onDec});
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        const Icon(Icons.image),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[ Text(product.name), Text('£${product.price}'), ])),
        IconButton(onPressed: onDec, icon: const Icon(Icons.remove_circle_outline)),
        Text(item.qty.toString()),
        IconButton(onPressed: onInc, icon: const Icon(Icons.add_circle_outline)),
      ]),
    );
  }
}
