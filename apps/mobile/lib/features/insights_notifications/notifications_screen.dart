import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'repo.dart';
import '../../widgets/pinto_coin_badge.dart';

final notificationsProvider = FutureProvider((ref) => ref.read(insightsRepoProvider).notifications());

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref){
    final data = ref.watch(notificationsProvider);
    return Scaffold(appBar: AppBar(title: const Text('Notifications')), body: data.when(
      loading: ()=> const Center(child:CircularProgressIndicator()),
      error: (e,_)=> Center(child: TextButton(onPressed: ()=> ref.refresh(notificationsProvider), child: const Text('Retry'))),
      data: (l){ if(l.isEmpty) return const Center(child: Text('All caught up 🎉')); return ListView.separated(padding: const EdgeInsets.all(16), itemCount: l.length, separatorBuilder: (_, __)=> const SizedBox(height:10), itemBuilder:(c,i){ final n=l[i]; return _AnimatedIn(index: i, child: Dismissible(key: ValueKey(n.id), onDismissed:(_){}, background: Container(color: Colors.redAccent.withOpacity(0.3)), child: GlassCard(child: ListTile(leading: Icon(_icon(n.type)), title: Text(n.title), subtitle: Text(n.body), trailing: n.cta==null? null : AppButtons.primary(label: n.cta!, onPressed: () async { await ref.read(insightsRepoProvider).act(n.id); // Special bounce for rewards
        if(n.type == 'rewards') { ref.read(pintoEarnedProvider.notifier).state += 1; }
        ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('Action completed'))); ref.refresh(notificationsProvider); })))); }); }
    ));
  }
}

IconData _icon(String t){
  switch(t){
    case 'bill_due': return Icons.receipt_long;
    case 'rewards': return Icons.stars;
    case 'repayment': return Icons.schedule;
    case 'security': return Icons.lock_outline;
  }
  return Icons.notifications_none;
}

class _AnimatedIn extends StatelessWidget {
  final int index; final Widget child; const _AnimatedIn({required this.index, required this.child});
  @override
  Widget build(BuildContext context){
    final delay = (80 * index).clamp(0, 600);
    return TweenAnimationBuilder<Offset>(
      duration: Duration(milliseconds: 350 + delay),
      curve: Curves.easeOutBack,
      tween: Tween(begin: const Offset(0, .1), end: Offset.zero),
      builder: (c, off, w) => Transform.translate(offset: off * 40, child: Opacity(opacity: 1 - off.dy, child: w)),
      child: child,
    );
  }
}
