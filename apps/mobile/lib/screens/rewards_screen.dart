import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pinto_model.dart';
import '../models/store_item_model.dart';
import '../widgets/pinto_balance_card.dart';
import '../widgets/store_item_card.dart';

final pintoRepositoryProvider = Provider<PintoRepository>((ref) => PintoRepositoryHttp());
final storeRepositoryProvider = Provider<StoreRepository>((ref) => StoreRepositoryHttp());

final pintoBalanceProvider = FutureProvider<int>((ref) async => ref.read(pintoRepositoryProvider).balance());
final pintoLedgerProvider = FutureProvider<List<PintoTransaction>>((ref) async => ref.read(pintoRepositoryProvider).ledger());
final storeItemsProvider = FutureProvider<List<StoreItem>>((ref) async => ref.read(storeRepositoryProvider).list());

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bal = ref.watch(pintoBalanceProvider);
    final items = ref.watch(storeItemsProvider);
    final earnedThisMonth = 250; // stub stat

    return Scaffold(
      appBar: AppBar(title: const Text('Rewards')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            PintoBalanceCard(
              balance: bal.asData?.value ?? 0,
              earnedThisMonth: earnedThisMonth,
              onViewLedger: () => _showLedger(context, ref),
            ),
            const SizedBox(height: 16),
            DefaultTabController(
              length: 3,
              child: Expanded(
                child: Column(
                  children: [
                    const TabBar(tabs: [
                      Tab(text: 'Gift Cards'),
                      Tab(text: 'Cashback'),
                      Tab(text: 'Store'),
                    ]),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TabBarView(children: [
                        _StoreList(items: items, ref: ref),
                        _CashbackStub(),
                        _StoreList(items: items, ref: ref),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLedger(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _LedgerModal(),
    );
  }
}

class _StoreList extends StatelessWidget {
  final AsyncValue<List<StoreItem>> items;
  final WidgetRef ref;
  const _StoreList({required this.items, required this.ref});

  @override
  Widget build(BuildContext context) {
    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: TextButton(onPressed: () => ref.refresh(storeItemsProvider), child: const Text('Retry'))),
      data: (list) => ListView.separated(
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => StoreItemCard(
          item: list[i],
          onRedeem: () async {
            final pinto = ref.read(pintoRepositoryProvider);
            try {
              await pinto.redeem(list[i].id);
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Redeemed successfully')));
              ref.invalidate(pintoBalanceProvider);
              ref.invalidate(pintoLedgerProvider);
            } catch (_) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient balance')));
            }
          },
        ),
      ),
    );
  }
}

class _CashbackStub extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Center(child: Text('Cashback offers coming soon'));
}

class _LedgerModal extends ConsumerWidget {
  const _LedgerModal();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledger = ref.watch(pintoLedgerProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pinto Ledger', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 420,
              child: ledger.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Failed to load ledger')),
                data: (txns) => txns.isEmpty
                    ? const Center(child: Text('No transactions yet'))
                    : ListView.separated(
                        itemCount: txns.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final t = txns[i];
                          final sign = t.type == PintoTxnType.earn ? '+' : '-';
                          final color = t.type == PintoTxnType.earn ? Colors.greenAccent : Colors.redAccent;
                          return ListTile(
                            title: Text(t.source),
                            subtitle: Text(t.date.toIso8601String().substring(0, 10)),
                            trailing: Text('$sign${t.amount}', style: TextStyle(color: color)),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
