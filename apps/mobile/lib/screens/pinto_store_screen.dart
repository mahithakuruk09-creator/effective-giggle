import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/store_item_model.dart';
import '../models/pinto_model.dart';
import '../widgets/store_item_card.dart';

final storeProvider = Provider<StoreRepository>((ref) => StoreRepositoryHttp());
final storeItemsProvider2 = FutureProvider<List<StoreItem>>((ref) async => ref.read(storeProvider).list());
final pintoRepoProvider = Provider<PintoRepository>((ref) => PintoRepositoryHttp());

class PintoStoreScreen extends ConsumerWidget {
  const PintoStoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(storeItemsProvider2);
    return Scaffold(
      appBar: AppBar(title: const Text('Pinto Store')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _FilterBar(onChanged: (c) => ref.refresh(storeItemsProvider2)),
            const SizedBox(height: 12),
            Expanded(
              child: items.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: TextButton(onPressed: () => ref.refresh(storeItemsProvider2), child: const Text('Retry'))),
                data: (list) => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, i) => StoreItemCard(
                    item: list[i],
                    onRedeem: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Confirm Redeem'),
                          content: Text('Redeem for ${list[i].price} Pintos?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                            ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Redeem')),
                          ],
                        ),
                      );
                      if (ok != true) return;
                      try {
                        await ref.read(pintoRepoProvider).redeem(list[i].id);
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Redeemed successfully')));
                      } catch (_) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient balance')));
                      }
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final ValueChanged<String?> onChanged;
  const _FilterBar({required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Icon(Icons.filter_list),
      const SizedBox(width: 8),
      Expanded(
        child: DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Category'),
          items: const [
            DropdownMenuItem(value: 'All', child: Text('All')),
            DropdownMenuItem(value: 'Food', child: Text('Food')),
            DropdownMenuItem(value: 'Travel', child: Text('Travel')),
            DropdownMenuItem(value: 'Retail', child: Text('Retail')),
            DropdownMenuItem(value: 'Experiences', child: Text('Experiences')),
          ],
          value: 'All',
          onChanged: onChanged,
        ),
      ),
    ]);
  }
}
