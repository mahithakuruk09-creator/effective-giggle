import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoanOfferCard extends StatelessWidget {
  final String id;
  final double apr; // e.g., 12.5
  final int amount; // GBP
  final int termMonths; // months
  final int monthlyRepayment; // GBP
  final VoidCallback onApply;
  const LoanOfferCard({super.key, required this.id, required this.apr, required this.amount, required this.termMonths, required this.monthlyRepayment, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 260,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Offer $id', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _pill('${apr.toStringAsFixed(1)}% APR'),
            _pill('£$amount'),
            _pill('$termMonths mo'),
            _pill('£$monthlyRepayment/mo'),
          ]),
          const Spacer(),
          AppButtons.primary(label: 'Apply', onPressed: onApply, icon: Icons.arrow_forward),
        ],
      ),
    );
  }

  Widget _pill(String text) => Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Text(text),
      );
}

