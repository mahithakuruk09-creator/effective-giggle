import 'dart:convert';

class Biller {
  final String id;
  final String category;
  final String name;
  final String logo;
  final double dueAmount;
  final DateTime dueDate;
  final String status; // 'due' or 'overdue'

  Biller({
    required this.id,
    required this.category,
    required this.name,
    required this.logo,
    required this.dueAmount,
    required this.dueDate,
    required this.status,
  });

  factory Biller.fromJson(Map<String, dynamic> json) => Biller(
        id: json['id'] as String,
        category: json['category'] as String,
        name: json['name'] as String,
        logo: json['logo'] as String,
        dueAmount: (json['due_amount'] as num).toDouble(),
        dueDate: DateTime.parse(json['due_date'] as String),
        status: json['status'] as String,
      );

  static List<Biller> listFromJson(String data) {
    final List<dynamic> decoded = json.decode(data) as List<dynamic>;
    return decoded.map((e) => Biller.fromJson(e as Map<String, dynamic>)).toList();
  }
}
