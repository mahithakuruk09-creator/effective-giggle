import 'package:go_router/go_router.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/auth/twofa_screen.dart';
import 'features/auth/password_reset_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/bill_pay/billers_hub_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
        path: '/2fa',
        builder: (context, state) =>
            TwoFAScreen(token: state.extra as String)),
    GoRoute(
        path: '/reset-password',
        builder: (context, state) => const PasswordResetScreen()),
    GoRoute(path: '/home', builder: (context, state) => const DashboardScreen()),
    GoRoute(path: '/billers', builder: (context, state) => const BillersHubScreen()),
  ],
);
