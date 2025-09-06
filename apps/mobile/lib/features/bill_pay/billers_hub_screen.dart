import 'package:flutter/material.dart';
import 'package:scredex_design_system/colors.dart';
import 'package:scredex_design_system/widgets/custom_button.dart';

import 'biller.dart';
import 'biller_service.dart';
import 'pay_bill_screen.dart';

class BillersHubScreen extends StatefulWidget {
  const BillersHubScreen({super.key});

  @override
  State<BillersHubScreen> createState() => _BillersHubScreenState();
}

class _BillersHubScreenState extends State<BillersHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _service = BillerService();
  List<Biller> _billers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadBillers();
  }

  Future<void> _loadBillers() async {
    final billers = await _service.fetchBillers();
    setState(() => _billers = billers);
  }

  static const _categories = [
    'Credit Cards',
    'Utilities',
    'Council/Government',
    'Broadband',
    'Mobile',
    'Insurance',
    'Rent',
    'Charity',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScredexColors.background,
      appBar: AppBar(
        title: const Text('Billers'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((c) {
          final billers = _billers.where((b) => b.category == c).toList();
          if (billers.isEmpty) {
            return const Center(child: Text('No bills'));
          }
          return ListView.builder(
            itemCount: billers.length,
            itemBuilder: (context, i) {
              final b = billers[i];
              final overdue = b.status == 'overdue';
              return Card(
                color: ScredexColors.card,
                shape: RoundedRectangleBorder(
                  side: overdue
                      ? const BorderSide(color: Colors.red)
                      : BorderSide.none,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(b.logo)),
                  title: Text(b.name),
                  subtitle: Text('Due £${b.dueAmount.toStringAsFixed(2)} on ${b.dueDate.toLocal().toString().split(' ').first}'),
                  trailing: CustomButton(
                    label: 'Pay',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PayBillScreen(biller: b),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
