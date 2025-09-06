import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PintoBalanceCard extends StatelessWidget {
  final int balance;
  final int earnedThisMonth;
  final VoidCallback onViewLedger;
  const PintoBalanceCard({super.key, required this.balance, required this.earnedThisMonth, required this.onViewLedger});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      height: 140,
      radius: 24,
      child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.savings, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Your Pintos', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 700),
                        tween: Tween(begin: 0, end: balance.toDouble()),
                        builder: (context, value, _) => Text(
                          value.toInt().toString(),
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('+$earnedThisMonth this month', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.greenAccent.shade100)),
                    ],
                  ),
                ),
                AppButtons.primary(label: 'View Ledger', icon: Icons.receipt_long, onPressed: onViewLedger),
              ],
    );
  }
}
