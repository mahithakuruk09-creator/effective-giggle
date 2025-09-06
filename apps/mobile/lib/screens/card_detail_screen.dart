import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CardDetailScreen extends StatelessWidget {
  final String cardId;
  final String name;
  final String last4;
  const CardDetailScreen({super.key, required this.cardId, required this.name, required this.last4});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GlassCard(height: 160, child: Stack(children:[ Align(alignment: Alignment.topLeft, child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700))), Align(alignment: Alignment.bottomLeft, child: Text('**** **** **** $last4')) ])),
            const SizedBox(height: 16),
            GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [ ListTile(leading: Icon(Icons.edit), title: Text('Rename')), ListTile(leading: Icon(Icons.ac_unit), title: Text('Freeze/Unfreeze')), ListTile(leading: Icon(Icons.delete_outline), title: Text('Delete card')), ])),
          ],
        ),
      ),
    );
  }
}

