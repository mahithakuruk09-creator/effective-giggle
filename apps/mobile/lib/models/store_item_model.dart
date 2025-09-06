import 'dart:convert';
import 'package:http/http.dart' as http;

class StoreItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final int price; // Pintos
  final String imageUrl; // placeholder string

  const StoreItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
  });

  factory StoreItem.fromJson(Map<String, dynamic> j) => StoreItem(
        id: j['id'] as String,
        title: j['title'] as String,
        description: (j['description'] as String?) ?? '',
        category: j['category'] as String,
        price: (j['price'] as num).toInt(),
        imageUrl: (j['image_url'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'price': price,
        'image_url': imageUrl,
      };
}

abstract class StoreRepository {
  Future<List<StoreItem>> list();
  Future<StoreItem> get(String id);
}

class StoreRepositoryHttp implements StoreRepository {
  final String baseUrl;
  StoreRepositoryHttp({this.baseUrl = 'http://localhost:8000'});

  @override
  Future<StoreItem> get(String id) async {
    final uri = Uri.parse('$baseUrl/store/$id');
    final r = await _get(uri);
    return StoreItem.fromJson(r);
    }

  @override
  Future<List<StoreItem>> list() async {
    final uri = Uri.parse('$baseUrl/store');
    final data = await _getList(uri);
    return data.map((e) => StoreItem.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final r = await http.get(uri);
    if (r.statusCode >= 400) throw Exception('GET ${uri.path} failed');
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> _getList(Uri uri) async {
    final r = await http.get(uri);
    if (r.statusCode >= 400) throw Exception('GET ${uri.path} failed');
    final l = jsonDecode(r.body) as List<dynamic>;
    return l.cast<Map<String, dynamic>>();
  }
}

class StoreRepositoryFake implements StoreRepository {
  final List<StoreItem> _items;
  StoreRepositoryFake([List<StoreItem>? seed]) : _items = List.of(seed ?? _default());

  @override
  Future<StoreItem> get(String id) async => _items.firstWhere((e) => e.id == id);

  @override
  Future<List<StoreItem>> list() async => List.unmodifiable(_items);

  static List<StoreItem> _default() => const [
        StoreItem(id: 's1p500', title: 'Tesco £5 Voucher', description: 'Redeem in Tesco stores across UK', category: 'Retail', price: 500, imageUrl: 'tesco'),
        StoreItem(id: 's2p200', title: 'Greggs Coffee', description: 'Freshly brewed Greggs coffee', category: 'Food', price: 200, imageUrl: 'greggs'),
        StoreItem(id: 's3p800', title: 'Amazon £10 UK', description: 'Spend on Amazon UK', category: 'Retail', price: 800, imageUrl: 'amazon'),
        StoreItem(id: 's4p600', title: 'Deliveroo £7', description: 'Order from your favourites', category: 'Food', price: 600, imageUrl: 'deliveroo'),
        StoreItem(id: 's5p300', title: 'Pret Coffee', description: 'Pret a Manger hot drink', category: 'Food', price: 300, imageUrl: 'pret'),
        StoreItem(id: 's6p1200', title: 'Trainline £15', description: 'National rail travel credit', category: 'Travel', price: 1200, imageUrl: 'trainline'),
      ];
}

// For tests, override repository providers in screens.
