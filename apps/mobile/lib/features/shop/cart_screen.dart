import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'repo.dart';
import 'models.dart';
import 'widgets.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});
  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  List<CartItem> _items = const [];
  Map<String, Product> _products = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(shopRepositoryProvider);
    final items = await repo.cart();
    final prods = <String, Product>{};
    for (final it in items) {
      prods[it.productId] = await repo.product(it.productId);
    }
    if (!mounted) return;
    setState(() { _items = items; _products = prods; _loading = false; });
  }

  int get total => _items.fold(0, (sum, it) => sum + (_products[it.productId]?.price ?? 0) * it.qty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Expanded(
                child: _items.isEmpty
                    ? const Center(child: Text('Your cart is empty.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (c, i) => CartItemTile(
                              product: _products[_items[i].productId]!,
                              item: _items[i],
                              onInc: () async { final it = await ref.read(shopRepositoryProvider).updateCart(_items[i].id, _items[i].qty + 1); setState(() => _items[i] = it); },
                              onDec: () async {
                                final newQty = _items[i].qty - 1;
                                if (newQty <= 0) { await ref.read(shopRepositoryProvider).deleteCartItem(_items[i].id); setState(() => _items.removeAt(i)); }
                                else { final it = await ref.read(shopRepositoryProvider).updateCart(_items[i].id, newQty); setState(() => _items[i] = it); }
                              },
                            ),
                      ),
              ),
              GlassCard(
                child: Row(children: [
                  Text('Total: £$total', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  AppButtons.primary(label: 'Checkout', icon: Icons.lock, onPressed: _items.isEmpty ? null : () => context.go('/shop/checkout')),
                ]),
              ),
              const SizedBox(height: 12),
            ]),
    );
  }
}
