import 'package:flutter/material.dart';
import 'package:scredex_design_system/colors.dart';
import 'package:scredex_design_system/widgets/custom_button.dart';
import 'package:lottie/lottie.dart';

import 'biller.dart';
import 'biller_service.dart';

class PayBillScreen extends StatefulWidget {
  final Biller biller;
  const PayBillScreen({super.key, required this.biller});

  @override
  State<PayBillScreen> createState() => _PayBillScreenState();
}

class _PayBillScreenState extends State<PayBillScreen> {
  final _service = BillerService();
  int _step = 0;
  double _amount = 0;
  bool _authSuccess = false;

  @override
  void initState() {
    super.initState();
    _amount = widget.biller.dueAmount;
  }

  void _next() {
    setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScredexColors.background,
      appBar: AppBar(title: Text('Pay ${widget.biller.name}')),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildStep(),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        final pintos = _service.calculatePintos(_amount, widget.biller.category);
        return Padding(
          key: const ValueKey(0),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: widget.biller.dueAmount.toStringAsFixed(2),
                ),
                onChanged: (v) => setState(() {
                  _amount = double.tryParse(v) ?? widget.biller.dueAmount;
                }),
              ),
              const SizedBox(height: 12),
              Text('Pintos preview: $pintos'),
              const Spacer(),
              CustomButton(label: 'Continue', onPressed: _next),
            ],
          ),
        );
      case 1:
        return Center(
          key: const ValueKey(1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Authorise payment'),
              const SizedBox(height: 16),
              CustomButton(
                label: 'Stub Authorise',
                onPressed: () {
                  _authSuccess = true;
                  _next();
                },
              )
            ],
          ),
        );
      default:
        final pintos = _service.calculatePintos(_amount, widget.biller.category);
        return Center(
          key: const ValueKey(2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/animations/scredex_logo.json', height: 100),
              const SizedBox(height: 16),
              const Text('Payment Successful'),
              Text('£${_amount.toStringAsFixed(2)} to ${widget.biller.name}'),
              Text('You earned $pintos Pintos'),
              const SizedBox(height: 16),
              CustomButton(
                label: 'Done',
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        );
    }
  }
}
