import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pintoEarnedProvider = StateProvider<int>((_) => 0);

class PintoCoinBadge extends ConsumerWidget {
  const PintoCoinBadge({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earned = ref.watch(pintoEarnedProvider);
    return AnimatedScale(
      scale: 1 + (earned > 0 ? 0.2 : 0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.elasticOut,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.monetization_on_outlined),
          if (earned > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.amber.shade700, borderRadius: BorderRadius.circular(10)),
                child: Text('+$earned', style: const TextStyle(fontSize: 10, color: Colors.black)),
              ),
            ),
        ],
      ),
    );
  }
}

