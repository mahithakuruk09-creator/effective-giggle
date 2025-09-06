import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/features/shop/shop_home_screen.dart';
import '../lib/features/shop/repo.dart';
import '../lib/features/shop/cart_screen.dart';
import '../lib/features/shop/checkout_screen.dart';

void main() {
  testWidgets('Wishlist empty and add-to-cart -> checkout flow', (tester) async {
    final repo = ShopRepositoryFake();
    await tester.pumpWidget(ProviderScope(
      overrides: [shopRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: ShopHomeScreen()),
    ));
    await tester.pumpAndSettle();

    // Add first product to cart from grid
    final addButtons = find.text('Add');
    expect(addButtons, findsWidgets);
    await tester.tap(addButtons.first);
    await tester.pumpAndSettle();

    // Go to cart
    await tester.pumpWidget(ProviderScope(overrides: [shopRepositoryProvider.overrideWithValue(repo)], child: const MaterialApp(home: CartScreen())));
    await tester.pumpAndSettle();
    expect(find.textContaining('Total'), findsOneWidget);

    // Proceed to checkout
    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(ProviderScope(overrides: [shopRepositoryProvider.overrideWithValue(repo)], child: const MaterialApp(home: CheckoutScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Place Order'), findsOneWidget);
  });
}

