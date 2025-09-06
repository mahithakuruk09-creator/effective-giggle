import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../theme/app_theme.dart';

class LoanApplicationScreen extends StatefulWidget {
  final int? defaultAmount;
  final int? defaultTerm;
  const LoanApplicationScreen({super.key, this.defaultAmount, this.defaultTerm});

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _termCtrl = TextEditingController();
  String _purpose = 'Consolidation';
  bool _submitting = false;
  double _shake = 0;
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _amountCtrl.text = (widget.defaultAmount ?? 3000).toString();
    _termCtrl.text = (widget.defaultTerm ?? 24).toString();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _termCtrl.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loan Application')),
      body: Stack(children:[
        Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          transform: Matrix4.translationValues(_shake, 0, 0),
          child: GlassCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Amount (£)'),
                    validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter a valid amount' : null,
                  ),
                  TextFormField(
                    controller: _termCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Term (months)'),
                    validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter a valid term' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _purpose,
                    items: const [
                      DropdownMenuItem(value: 'Consolidation', child: Text('Consolidation')),
                      DropdownMenuItem(value: 'Home', child: Text('Home')),
                      DropdownMenuItem(value: 'Car', child: Text('Car')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (v) => setState(() => _purpose = v ?? _purpose),
                    decoration: const InputDecoration(labelText: 'Purpose'),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButtons.primary(
                      label: _submitting ? 'Submitting…' : 'Submit',
                      icon: Icons.check,
                      onPressed: _submitting
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) {
                                setState(() => _shake = _shake == 0 ? 10 : -_shake);
                                await Future.delayed(const Duration(milliseconds: 120));
                                setState(() => _shake = 0);
                                return;
                              }
                              setState(() => _submitting = true);
                              await Future.delayed(const Duration(milliseconds: 500));
                              if (!mounted) return;
                              setState(() => _submitting = false);
                              // Result modal
                              // ignore: use_build_context_synchronously
                              showModalBottomSheet(
                                context: context,
                                showDragHandle: true,
                                builder: (_) => const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('Eligibility: You are likely eligible. An agent will contact you.'),
                                ),
                              );
                            },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _confetti, blastDirectionality: BlastDirectionality.explosive, numberOfParticles: 16)),
      ]),
    );
  }
}
