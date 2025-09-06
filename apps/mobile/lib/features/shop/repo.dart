import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

abstract class ShopRepository {
  Future<List<Product>> products({String? category, String? search});
  Future<Product> product(String id);
  Future<List<CartItem>> cart();
  Future<CartItem> addToCart(String productId, int qty);
  Future<CartItem> updateCart(String cartItemId, int qty);
  Future<void> deleteCartItem(String cartItemId);
  Future<Order> checkout({int redeem = 0});
  Future<List<Order>> orders();
  Future<List<String>> wishlist();
  Future<void> addWishlist(String productId);
  Future<void> removeWishlist(String productId);
  Future<RewardAccount> rewards();
}

class ShopRepositoryHttp implements ShopRepository {
  final String baseUrl;
  ShopRepositoryHttp({this.baseUrl = 'http://localhost:8000'});

  @override
  Future<CartItem> addToCart(String productId, int qty) async {
    final r = await http.post(Uri.parse('$baseUrl/shop/cart/items'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'product_id': productId, 'qty': qty}));
    if (r.statusCode >= 400) throw Exception('add cart failed');
    return CartItem.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  @override
  Future<Order> checkout({int redeem = 0}) async {
    final r = await http.post(Uri.parse('$baseUrl/shop/orders/checkout'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'redeem': redeem}));
    if (r.statusCode >= 400) throw Exception('checkout failed');
    return Order.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  @override
  Future<List<Order>> orders() async {
    final r = await http.get(Uri.parse('$baseUrl/shop/orders'));
    if (r.statusCode >= 400) throw Exception('orders failed');
    final l = jsonDecode(r.body) as List<dynamic>;
    return l.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CartItem>> cart() async {
    final r = await http.get(Uri.parse('$baseUrl/shop/cart'));
    if (r.statusCode >= 400) throw Exception('cart failed');
    final l = jsonDecode(r.body) as List<dynamic>;
    return l.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> deleteCartItem(String cartItemId) async {
    final r = await http.delete(Uri.parse('$baseUrl/shop/cart/items/$cartItemId'));
    if (r.statusCode >= 400) throw Exception('delete cart failed');
  }

  @override
  Future<Product> product(String id) async {
    final r = await http.get(Uri.parse('$baseUrl/shop/products/$id'));
    if (r.statusCode >= 400) throw Exception('product failed');
    return Product.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  @override
  Future<List<Product>> products({String? category, String? search}) async {
    final qs = [if (category != null) 'category=$category', if (search != null) 'search=$search'].join('&');
    final r = await http.get(Uri.parse('$baseUrl/shop/products${qs.isEmpty ? '' : '?$qs'}'));
    if (r.statusCode >= 400) throw Exception('products failed');
    final l = jsonDecode(r.body) as List<dynamic>;
    return l.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<CartItem> updateCart(String cartItemId, int qty) async {
    final r = await http.put(Uri.parse('$baseUrl/shop/cart/items/$cartItemId'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'qty': qty}));
    if (r.statusCode == 410) {
      // deleted on server when qty<=0
      throw Exception('deleted');
    }
    if (r.statusCode >= 400) throw Exception('update cart failed');
    return CartItem.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  @override
  Future<List<String>> wishlist() async {
    final r = await http.get(Uri.parse('$baseUrl/shop/wishlist'));
    if (r.statusCode >= 400) throw Exception('wishlist failed');
    return (jsonDecode(r.body) as Map<String, dynamic>)['items'].cast<String>();
  }

  @override
  Future<void> addWishlist(String productId) async {
    final r = await http.post(Uri.parse('$baseUrl/shop/wishlist/$productId'));
    if (r.statusCode >= 400) throw Exception('add wishlist failed');
  }

  @override
  Future<void> removeWishlist(String productId) async {
    final r = await http.delete(Uri.parse('$baseUrl/shop/wishlist/$productId'));
    if (r.statusCode >= 400) throw Exception('del wishlist failed');
  }

  @override
  Future<RewardAccount> rewards() async {
    final r = await http.get(Uri.parse('$baseUrl/shop/rewards'));
    if (r.statusCode >= 400) throw Exception('rewards failed');
    return RewardAccount.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }
}

class ShopRepositoryFake implements ShopRepository {
  List<Product> _seed = const [
    Product(id: 'p1', name: 'Monochrome Hoodie', category: 'Apparel', price: 59, stock: 20, images: ['hoodie1'], variants: [], description: ''),
    Product(id: 'p2', name: 'Wireless Earbuds', category: 'Gadgets', price: 79, stock: 20, images: ['buds1'], variants: [], description: ''),
  ];
  final List<CartItem> _cart = [];
  int balance = 0;

  @override
  Future<CartItem> addToCart(String productId, int qty) async {
    final id = 'ci${_cart.length + 1}';
    final existing = _cart.where((e) => e.productId == productId).toList();
    if (existing.isNotEmpty) {
      final i = _cart.indexOf(existing.first);
      _cart[i] = CartItem(id: _cart[i].id, productId: productId, qty: _cart[i].qty + qty);
      return _cart[i];
    }
    final it = CartItem(id: id, productId: productId, qty: qty);
    _cart.add(it);
    return it;
  }

  @override
  Future<List<CartItem>> cart() async => List.unmodifiable(_cart);

  @override
  Future<Order> checkout({int redeem = 0}) async {
    int total = 0;
    for (final it in _cart) {
      final p = _seed.firstWhere((e) => e.id == it.productId);
      total += p.price * it.qty;
    }
    final use = redeem.clamp(0, balance).clamp(0, total);
    balance -= use;
    final payable = total - use;
    balance += payable; // earn
    _cart.clear();
    return Order(id: 'o1', total: total, status: 'confirmed');
  }

  @override
  Future<List<Order>> orders() async => [Order(id: 'o1', total: 138, status: 'confirmed')];

  @override
  Future<void> deleteCartItem(String cartItemId) async {
    _cart.removeWhere((e) => e.id == cartItemId);
  }

  @override
  Future<Product> product(String id) async => _seed.firstWhere((e) => e.id == id);

  @override
  Future<List<Product>> products({String? category, String? search}) async {
    var l = _seed;
    if (category != null) l = l.where((e) => e.category == category).toList();
    if (search != null) l = l.where((e) => e.name.toLowerCase().contains(search.toLowerCase())).toList();
    return l;
  }

  @override
  Future<CartItem> updateCart(String cartItemId, int qty) async {
    final i = _cart.indexWhere((e) => e.id == cartItemId);
    if (i < 0) throw Exception('missing');
    _cart[i] = CartItem(id: cartItemId, productId: _cart[i].productId, qty: qty);
    return _cart[i];
  }

  @override
  Future<void> addWishlist(String productId) async {}

  @override
  Future<List<String>> wishlist() async => const [];

  @override
  Future<void> removeWishlist(String productId) async {}

  @override
  Future<RewardAccount> rewards() async => RewardAccount(userId: 'u1', balance: balance);
}
