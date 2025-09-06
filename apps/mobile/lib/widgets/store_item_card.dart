import 'package:flutter/material.dart';
import '../models/store_item_model.dart';
import '../theme/app_theme.dart';

class StoreItemCard extends StatelessWidget {
  final StoreItem item;
  final VoidCallback onRedeem;
  const StoreItemCard({super.key, required this.item, required this.onRedeem});

  IconData _iconFor(String image) {
    switch (image.toLowerCase()) {
      case 'tesco':
        return Icons.shopping_basket;
      case 'amazon':
        return Icons.local_mall;
      case 'greggs':
        return Icons.local_cafe;
      case 'pret':
        return Icons.coffee;
      case 'deliveroo':
        return Icons.delivery_dining;
      case 'trainline':
        return Icons.train;
      default:
        return Icons.card_giftcard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Icon(_iconFor(item.imageUrl), size: 42),
                ),
              ),
              const SizedBox(height: 6),
              Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('${item.price} Pintos', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: AppButtons.primary(label: 'Redeem', onPressed: onRedeem, icon: Icons.card_giftcard))
            ],
          ),
    );
  }
}
