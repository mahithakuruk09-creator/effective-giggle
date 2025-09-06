import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int amount; // positive/negative indicates direction
  const CardTile({super.key, required this.icon, required this.title, required this.subtitle, required this.amount});

  @override
  Widget build(BuildContext context) {
    final sign = amount >= 0 ? '+' : '-';
    final color = amount >= 0 ? AppColors.success : AppColors.error;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title), Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted))])),
          Text('$sign£${amount.abs()}', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

