import 'dart:math';
import 'package:flutter/material.dart';
import 'package:scredex_design_system/design_system.dart';
import 'dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late Future<DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = DashboardService().fetchDashboard();
  }

  Future<void> _refresh() async {
    final data = await DashboardService().fetchDashboard();
    setState(() {
      _future = Future.value(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScredexColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  content: Text('Balances refreshed daily via Open Banking (TrueLayer)'),
                ),
              );
            },
          )
        ],
      ),
      body: FutureBuilder<DashboardData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Failed to load'),
                  const SizedBox(height: 8),
                  ScredexButton(label: 'Retry', onPressed: _refresh),
                ],
              ),
            );
          }
          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _BalancesCard(data: data),
                const SizedBox(height: 24),
                _BillsSection(bills: data.bills),
                const SizedBox(height: 24),
                _CreditScoreSection(score: data.creditScore),
                const SizedBox(height: 24),
                _QuickActions(),
                const SizedBox(height: 24),
                _SpendingTrend(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BalancesCard extends StatelessWidget {
  final DashboardData data;
  const _BalancesCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ScredexColors.card.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wallet: £${data.walletBalance.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...data.linkedAccounts
              .map((a) => Text('${a.bank}: £${a.balance.toStringAsFixed(2)}')),
          const SizedBox(height: 8),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: data.pintosBalance),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) => Text('Pintos: $value'),
          ),
        ],
      ),
    );
  }
}

class _BillsSection extends StatelessWidget {
  final List<Bill> bills;
  const _BillsSection({required this.bills});

  @override
  Widget build(BuildContext context) {
    if (bills.isEmpty) {
      return const Text('No bills due');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bills Due This Week', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final b = bills[index];
              return Container(
                width: 160,
                decoration: BoxDecoration(
                  color: ScredexColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: b.status == 'overdue'
                      ? Border.all(color: Colors.red)
                      : null,
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Center(
                        child: Image.network(b.logoUrl, height: 40, errorBuilder: (_, __, ___) => const Icon(Icons.receipt_long)),
                      ),
                    ),
                    Text(b.name),
                    Text('Due ${b.dueDate.day}/${b.dueDate.month}'),
                    Text('£${b.amount.toStringAsFixed(2)}'),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(onPressed: () {}, child: const Text('Pay')),
                    )
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: bills.length,
          ),
        ),
      ],
    );
  }
}

class _CreditScoreSection extends StatefulWidget {
  final CreditScore score;
  const _CreditScoreSection({required this.score});

  @override
  State<_CreditScoreSection> createState() => _CreditScoreSectionState();
}

class _CreditScoreSectionState extends State<_CreditScoreSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Credit Score', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final value = widget.score.value / 850 * _controller.value;
              return CustomPaint(
                painter: _DialPainter(value),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.score.value.toString(),
                          style: Theme.of(context).textTheme.headlineMedium),
                      Text(widget.score.band),
                      Text('Refreshed ${widget.score.lastRefreshed.toLocal().toString().split(' ').first}')
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DialPainter extends CustomPainter {
  final double value; // 0-1
  _DialPainter(this.value);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = ScredexColors.accent;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        pi, pi * value, false, paint);
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) => oldDelegate.value != value;
}

class _QuickActions extends StatelessWidget {
  final List<_ActionItem> actions = const [
    _ActionItem(icon: Icons.receipt_long, label: 'Pay Bill'),
    _ActionItem(icon: Icons.card_giftcard, label: 'Redeem'),
    _ActionItem(icon: Icons.monetization_on, label: 'Apply Loan'),
    _ActionItem(icon: Icons.add, label: 'Add Biller'),
  ];
  _QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 4,
      children: actions
          .map((a) => GestureDetector(
                onTap: () {
                  if (a.label == 'Pay Bill') {
                    Navigator.of(context).pushNamed('/billers');
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ScredexColors.card,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(a.icon),
                    ),
                    const SizedBox(height: 4),
                    Text(a.label, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  const _ActionItem({required this.icon, required this.label});
}

class _SpendingTrend extends StatelessWidget {
  final List<double> data = const [20, 40, 30, 50, 60, 30, 20];
  _SpendingTrend({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Spending Trend', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: CustomPaint(
            painter: _SparklinePainter(data),
          ),
        ),
        const SizedBox(height: 8),
        const Text('Based on linked accounts (AIS stub).',
            style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  _SparklinePainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ScredexColors.accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    final stepX = size.width / (values.length - 1);
    for (int i = 0; i < values.length; i++) {
      final x = stepX * i;
      final y = size.height - (values[i] / (values.reduce(max)) * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => false;
}
