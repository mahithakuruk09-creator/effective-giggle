import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InsightCard extends StatelessWidget {
  final String factor; // e.g. utilisation
  final String value; // e.g. 42%
  final String recommendation; // e.g. Reduce below 30%
  const InsightCard({super.key, required this.factor, required this.value, required this.recommendation});

  IconData _iconFor(String f) {
    switch (f) {
      case 'utilisation':
        return Icons.speed;
      case 'payment_history':
        return Icons.history_toggle_off;
      case 'length_of_history':
        return Icons.timeline;
      case 'enquiries':
        return Icons.search;
      case 'mix':
        return Icons.all_inbox;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_iconFor(factor), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_labelize(factor), style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text(recommendation),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _labelize(String f) => f
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : (w[0].toUpperCase() + w.substring(1)))
      .join(' ');
}

