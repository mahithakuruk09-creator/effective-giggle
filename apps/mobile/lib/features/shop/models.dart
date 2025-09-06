import 'dart:convert';

class Product {
  final String id;
  final String name;
  final String category; // Apparel, Gadgets, Lifestyle, Digital
  final int price; // GBP
  final int stock;
  final List<String> images;
  final List<Variant> variants;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.images,
    required this.variants,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String,
        name: j['name'] as String,
        category: j['category'] as String,
        price: (j['price'] as num).toInt(),
        stock: (j['stock'] as num).toInt(),
        images: (j['images'] as List).cast<String>(),
        variants: ((j['variants'] as List?) ?? const []).map((e) => Variant.fromJson(e as Map<String, dynamic>)).toList(),
        description: (j['description'] as String?) ?? '',
      );
}

class Variant {
  final String id;
  final String productId;
  final String option;
  final int stock;
  const Variant({required this.id, required this.productId, required this.option, required this.stock});
  factory Variant.fromJson(Map<String, dynamic> j) => Variant(
        id: j['id'] as String,
        productId: j['product_id'] as String,
        option: j['option'] as String,
        stock: (j['stock'] as num).toInt(),
      );
}

class Review {
  final String id;
  final String productId;
  final int rating;
  final String comment;
  const Review({required this.id, required this.productId, required this.rating, required this.comment});
  factory Review.fromJson(Map<String, dynamic> j) => Review(
        id: j['id'] as String,
        productId: j['product_id'] as String,
        rating: (j['rating'] as num).toInt(),
        comment: j['comment'] as String,
      );
}

class CartItem {
  final String id;
  final String productId;
  final int qty;
  const CartItem({required this.id, required this.productId, required this.qty});
  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(id: j['id'], productId: j['product_id'], qty: (j['qty'] as num).toInt());
}

class Order {
  final String id;
  final int total;
  final String status;
  const Order({required this.id, required this.total, required this.status});
  factory Order.fromJson(Map<String, dynamic> j) => Order(id: j['id'], total: (j['total'] as num).toInt(), status: j['status']);
}

class RewardAccount { final String userId; final int balance; const RewardAccount({required this.userId, required this.balance}); factory RewardAccount.fromJson(Map<String,dynamic> j)=>RewardAccount(userId: j['user_id'] ?? 'u1', balance: (j['balance'] as num).toInt()); }

