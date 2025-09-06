import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/screens.dart';
import 'features/shop/shop_home_screen.dart';
import 'features/shop/cart_screen.dart';
import 'features/shop/wishlist_screen.dart';
import 'features/shop/checkout_screen.dart';
import 'features/shop/order_history_screen.dart';
import 'features/insights_notifications/insights_screen.dart';
import 'features/insights_notifications/notifications_screen.dart';
import 'features/virtual_finance_layer/wallet_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/home',
  routes: [
    ShellRoute(
      navigatorKey: _shellKey,
      builder: (context, state, child) => Scaffold(
        body: child,
        bottomNavigationBar: _NavBar(current: state.location),
      ),
      routes: [
        GoRoute(path: '/home',    builder: (c, s) => const HomeScreen()),
        GoRoute(path: '/billers', builder: (c, s) => const BillersHubScreen()),
        GoRoute(path: '/rewards', builder: (c, s) => const RewardsScreen()),
        GoRoute(path: '/offers',  builder: (c, s) => const OffersScreen()),
        GoRoute(path: '/profile', builder: (c, s) => const ProfileSettingsScreen()),
      ],
    ),
    GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
    GoRoute(path: '/auth',       builder: (c, s) => const AuthScreen()),
    GoRoute(path: '/pay-bill',   builder: (c, s) => const PayBillScreen()),
    GoRoute(path: '/autopay',    builder: (c, s) => const AutopayManagerScreen()),
    GoRoute(path: '/store',      builder: (c, s) => const PintoStoreScreen()),
    GoRoute(path: '/credit',     builder: (c, s) => const CreditScoreInsightsScreen()),
    GoRoute(path: '/loans',      builder: (c, s) => const LoansCreditScreen()),
    GoRoute(path: '/cards',      builder: (c, s) => const CardsWalletScreen()),
    // Replace old insights/notifications with new Phase 14 screens
    GoRoute(path: '/insights',   builder: (c, s) => const InsightsScreen()),
    GoRoute(path: '/notifications', builder: (c, s) => const NotificationsScreen()),
    GoRoute(path: '/support',    builder: (c, s) => const SupportTrustScreen()),
    // Shop / E-commerce
    GoRoute(path: '/shop',          builder: (c, s) => const ShopHomeScreen()),
    GoRoute(path: '/shop/cart',     builder: (c, s) => const CartScreen()),
    GoRoute(path: '/shop/wishlist', builder: (c, s) => const WishlistScreen()),
    GoRoute(path: '/shop/checkout', builder: (c, s) => const CheckoutScreen()),
    GoRoute(path: '/shop/orders',   builder: (c, s) => const OrderHistoryScreen()),
    // Virtual Finance Layer (Mock Weavr/Railsr)
    GoRoute(path: '/wallet', builder: (c, s) => const WalletVflScreen()),
  ],
);

class _NavBar extends StatelessWidget {
  final String current;
  const _NavBar({required this.current});

  int _index(String loc) {
    switch (loc) {
      case '/home': return 0;
      case '/billers': return 1;
      case '/rewards': return 2;
      case '/offers': return 3;
      case '/profile': return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _index(current),
      onTap: (i) {
        switch (i) {
          case 0: context.go('/home'); break;
          case 1: context.go('/billers'); break;
          case 2: context.go('/rewards'); break;
          case 3: context.go('/offers'); break;
          case 4: context.go('/profile'); break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Bills'),
        BottomNavigationBarItem(icon: Icon(Icons.stars), label: 'Rewards'),
        BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Offers'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
