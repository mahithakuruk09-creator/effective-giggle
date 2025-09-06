import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScoreSimulator extends StatefulWidget {
  final Future<void> Function(List<String> actions) onSimulate;
  const ScoreSimulator({super.key, required this.onSimulate});

  @override
  State<ScoreSimulator> createState() => _ScoreSimulatorState();
}

class _ScoreSimulatorState extends State<ScoreSimulator> {
  bool pay500 = false;
  bool reduceUtil = true;
  bool closeOldest = false;
  bool addNewLine = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Score Simulator', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SwitchListTile(
            value: pay500,
            onChanged: (v) => setState(() => pay500 = v),
            title: const Text('Pay £500 off credit card'),
          ),
          SwitchListTile(
            value: reduceUtil,
            onChanged: (v) => setState(() => reduceUtil = v),
            title: const Text('Reduce utilisation to 30%'),
          ),
          SwitchListTile(
            value: closeOldest,
            onChanged: (v) => setState(() => closeOldest = v),
            title: const Text('Close oldest card'),
          ),
          SwitchListTile(
            value: addNewLine,
            onChanged: (v) => setState(() => addNewLine = v),
            title: const Text('Add new credit line'),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: AppButtons.primary(
              label: loading ? 'Simulating…' : 'Simulate',
              icon: Icons.trending_up,
              onPressed: loading
                  ? null
                  : () async {
                      setState(() => loading = true);
                      final actions = <String>[];
                      if (pay500) actions.add('pay_500');
                      if (reduceUtil) actions.add('reduce_utilisation');
                      if (closeOldest) actions.add('close_oldest');
                      if (addNewLine) actions.add('add_new_line');
                      await widget.onSimulate(actions);
                      if (mounted) setState(() => loading = false);
                    },
            ),
          )
        ],
      ),
    );
  }
}

