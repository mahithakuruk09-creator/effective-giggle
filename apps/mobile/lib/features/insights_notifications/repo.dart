import 'dart:convert';
import 'package:http/http.dart' as http;

class SpendingCategory { final String category; final int amount; final double percentage; SpendingCategory(this.category,this.amount,this.percentage); }
class SpendingTrend { final String month; final int total; SpendingTrend(this.month,this.total); }
class Tip { final String id; final String text; final String? category; final String createdAt; Tip(this.id,this.text,this.category,this.createdAt); }
class NotificationItem { final String id; final String type; final String title; final String body; final String? cta; String status; NotificationItem(this.id,this.type,this.title,this.body,this.cta,this.status); }

class InsightsBundle { final List<SpendingCategory> categories; final List<SpendingTrend> trends; final List<Tip> tips; InsightsBundle(this.categories,this.trends,this.tips); }

abstract class InsightsRepo {
  Future<InsightsBundle> spending();
  Future<List<NotificationItem>> notifications();
  Future<void> act(String id);
}

class InsightsRepoHttp implements InsightsRepo {
  final String baseUrl; InsightsRepoHttp({this.baseUrl='http://localhost:8000'});
  @override Future<void> act(String id) async { final r=await http.post(Uri.parse('$baseUrl/notifications/$id/action')); if(r.statusCode>=400) throw Exception('act'); }
  @override Future<List<NotificationItem>> notifications() async { final r=await http.get(Uri.parse('$baseUrl/notifications')); if(r.statusCode>=400) throw Exception('notifs'); final l=(jsonDecode(r.body) as List).cast<Map<String,dynamic>>(); return [for(final e in l) NotificationItem(e['id'],e['type'],e['title'],e['body'],e['cta'],e['status'])]; }
  @override Future<InsightsBundle> spending() async { final r=await http.get(Uri.parse('$baseUrl/insights/spending')); if(r.statusCode>=400) throw Exception('spending'); final j=jsonDecode(r.body) as Map<String,dynamic>; final cats=(j['categories'] as List).cast<Map<String,dynamic>>().map((e)=>SpendingCategory(e['category'], (e['amount'] as num).toInt(), (e['percentage'] as num).toDouble())).toList(); final trends=(j['trends'] as List).cast<Map<String,dynamic>>().map((e)=>SpendingTrend(e['month'], (e['total'] as num).toInt())).toList(); final tips=(j['tips'] as List).cast<Map<String,dynamic>>().map((e)=>Tip(e['id'], e['text'], e['category'], e['created_at'])).toList(); return InsightsBundle(cats,trends,tips); }
}

class InsightsRepoFake implements InsightsRepo {
  @override Future<void> act(String id) async {}
  @override Future<List<NotificationItem>> notifications() async => [NotificationItem('n1','rewards','Pintos earned','You earned 120', 'Redeem', 'unread')];
  @override Future<InsightsBundle> spending() async => InsightsBundle([SpendingCategory('Dining', 200, 0.2), SpendingCategory('Shopping', 300, 0.3)], [SpendingTrend('2025-08', 900), SpendingTrend('2025-09', 1000)], [Tip('t1','Dining up 20%','Dining','2025-09-06')]);
}

