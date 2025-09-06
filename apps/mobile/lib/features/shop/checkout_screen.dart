import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'repo.dart';
import '../../widgets/pinto_coin_badge.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int redeem = 0;
  bool placing = false;
  late final ConfettiController _confetti;

  @override
  void initState(){
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose(){ _confetti.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Stack(children:[
        Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [ Text('Shipping'), SizedBox(height:6), Text('Name Surname'), Text('221B Baker Street, London'), ])),
          const SizedBox(height: 12),
          GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [ Text('Payment Method'), SizedBox(height:6), Text('Wallet/Card (stub)'), ])),
          const SizedBox(height: 12),
          FutureBuilder(
            future: ref.read(shopRepositoryProvider).rewards(),
            builder: (context, snap) {
              final balance = snap.data?.balance ?? 0;
              return GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text('Pinto Redemption'), const SizedBox(height:6), Text('Balance: ' + balance.toString()), Slider(value: redeem.toDouble(), min: 0, max: balance.toDouble(), divisions: balance > 0 ? balance : 1, label: '£'+redeem.toString(), onChanged: (v){ setState(()=> redeem = v.toInt()); }) ]));
            },
          ),
          const Spacer(),
          Row(children:[ Expanded(child: AppButtons.primary(label: placing ? 'Placing…' : 'Place Order', icon: Icons.check_circle, onPressed: placing ? null : () async {
            setState(()=> placing = true);
            try {
              final order = await ref.read(shopRepositoryProvider).checkout(redeem: redeem);
              // refresh Pinto main balance too, if used elsewhere
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order successful!')));
                // bump in-app Pinto badge count (coin bounce)
                ref.read(pintoEarnedProvider.notifier).state += order.total;
                _confetti.play();
                // refresh rewards widget balance on home
                Navigator.popUntil(context, (r) => r.isFirst);
              }
            } catch (_) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checkout failed')));
            } finally {
              if (mounted) setState(()=> placing = false);
            }
          }))])
        ]),
      ),
        Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _confetti, blastDirectionality: BlastDirectionality.explosive, numberOfParticles: 18))
      ]),
    );
  }
}
