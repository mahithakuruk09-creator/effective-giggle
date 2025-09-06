import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'repo.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(shopRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: FutureBuilder(
        future: repo.orders(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final orders = snap.data!;
          if (orders.isEmpty) return const Center(child: Text('No orders yet'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (c, i) => GlassCard(
              child: ListTile(
                title: Text('Order ${orders[i].id}'),
                subtitle: Text('Status: ${orders[i].status}'),
                trailing: Text('£${orders[i].total}', style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          );
        },
      ),
    );
  }
}

