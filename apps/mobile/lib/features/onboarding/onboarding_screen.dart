import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scredex_design_system/design_system.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int _index = 0;
  late AnimationController _pulse;
  late Animation<double> _scale;

  final _pages = const [
    _OnboardData(
      icon: Icons.receipt_long,
      title: 'Bills',
      subtitle: 'Pay your credit cards, utilities, and more.',
    ),
    _OnboardData(
      icon: Icons.card_giftcard,
      title: 'Rewards',
      subtitle: 'Earn Pintos on every bill.',
    ),
    _OnboardData(
      icon: Icons.credit_score,
      title: 'Credit',
      subtitle: 'Track and build your credit score.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulse =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _scale = Tween(begin: 1.0, end: 1.05)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScredexColors.background,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => _buildPage(i),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: _complete,
              child: const Text('Skip'),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i
                        ? ScredexColors.accent
                        : ScredexColors.card,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          if (_index == _pages.length - 1)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: ScaleTransition(
                scale: _scale,
                child: ScredexButton(
                  label: 'Get Started',
                  onPressed: _complete,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    final data = _pages[index];
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double page = _controller.hasClients ? _controller.page ?? 0 : 0;
            double offset = (index - page) * constraints.maxWidth * 0.2;
            return Center(
              child: Transform.translate(
                offset: Offset(offset, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ScredexBlur.glass,
                    child: Container(
                      width: constraints.maxWidth * 0.8,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ScredexColors.card.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: ScredexColors.card.withOpacity(0.3)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(data.icon,
                              size: 120, color: ScredexColors.primary),
                          const SizedBox(height: 32),
                          Text(data.title,
                              style: ScredexTypography.heading),
                          const SizedBox(height: 16),
                          Text(
                            data.subtitle,
                            style: ScredexTypography.body,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _OnboardData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
