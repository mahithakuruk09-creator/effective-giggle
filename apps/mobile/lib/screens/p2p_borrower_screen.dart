import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class P2PBorrowerScreen extends StatefulWidget {
  const P2PBorrowerScreen({super.key});
  @override
  State<P2PBorrowerScreen> createState() => _P2PBorrowerScreenState();
}

class _P2PBorrowerScreenState extends State<P2PBorrowerScreen> {
  int _step = 0; // 0 pending, 1 funded, 2 active
  final _amount = TextEditingController(text: '2000');
  final _term = TextEditingController(text: '12');

  @override
  void dispose() { _amount.dispose(); _term.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('P2P Borrower')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children:[
          GlassCard(child: Column(children:[
            TextFormField(decoration: const InputDecoration(labelText: 'Amount (£)'), controller: _amount, keyboardType: TextInputType.number),
            TextFormField(decoration: const InputDecoration(labelText: 'Term (months)'), controller: _term, keyboardType: TextInputType.number),
            const SizedBox(height:8),
            Align(alignment: Alignment.centerRight, child: AppButtons.primary(label: 'Request Funding', onPressed: (){ setState(()=> _step = 0); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request submitted'))); }))
          ])),
          const SizedBox(height:16),
          GlassCard(child: Stepper(currentStep: _step, controlsBuilder: (_, __)=> const SizedBox.shrink(), steps: const [
            Step(title: Text('Pending'), content: Text('Awaiting investors')), Step(title: Text('Funded'), content: Text('Investment received')), Step(title: Text('Active'), content: Text('Repayments ongoing'))
          ])),
          const SizedBox(height:16),
          AppButtons.primary(label: 'Advance Status', onPressed: (){ setState(()=> _step = (_step + 1).clamp(0, 2)); }),
        ]),
      )
    );
  }
}

