import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/autopay_model.dart';

class AutopaySettingsResult {
  final String? autopayId; // null when creating
  final String billerId;
  final AutopayType type;
  final double? cap;
  final int preAlertDays;
  final bool enabled;
  const AutopaySettingsResult({
    this.autopayId,
    required this.billerId,
    required this.type,
    required this.cap,
    required this.preAlertDays,
    required this.enabled,
  });
}

class BillerDisplay {
  final String id;
  final String name;
  final IconData icon;
  final String dueLabel; // e.g. "Due 12th"
  const BillerDisplay(
      {required this.id,
      required this.name,
      required this.icon,
      required this.dueLabel});
}

class AutopaySettingsSheet extends StatefulWidget {
  final List<BillerDisplay> billers;
  final AutopaySettingsResult initial;

  const AutopaySettingsSheet({
    super.key,
    required this.billers,
    required this.initial,
  });

  @override
  State<AutopaySettingsSheet> createState() => _AutopaySettingsSheetState();
}

class _AutopaySettingsSheetState extends State<AutopaySettingsSheet> {
  late String billerId;
  late AutopayType type;
  double? cap;
  late int preAlertDays;
  late bool enabled;
  bool saving = false;
  final _capController = TextEditingController();
  final _currency = NumberFormat.currency(locale: 'en_GB', symbol: '£');

  @override
  void initState() {
    super.initState();
    billerId = widget.initial.billerId;
    type = widget.initial.type;
    cap = widget.initial.cap;
    preAlertDays = widget.initial.preAlertDays;
    enabled = widget.initial.enabled;
    if (cap != null) _capController.text = cap!.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _capController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final biller = widget.billers.firstWhere((b) => b.id == billerId,
        orElse: () => widget.billers.first);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(biller.icon),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: billerId,
                    items: widget.billers
                        .map((b) => DropdownMenuItem(
                              value: b.id,
                              child: Text(b.name,
                                  semanticsLabel: 'Biller ${b.name}'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => billerId = v ?? billerId),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<AutopayType>(
              value: type,
              decoration: const InputDecoration(labelText: 'Payment type'),
              items: AutopayType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.label,
                            semanticsLabel: 'Type ${t.label}'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => type = v ?? type),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _capController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Cap amount',
                prefixText: _currency.currencySymbol,
              ),
              onChanged: (v) => cap = double.tryParse(v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Pre-alert days'),
                Expanded(
                  child: Slider(
                    value: preAlertDays.toDouble(),
                    min: 0,
                    max: 7,
                    divisions: 7,
                    label: '$preAlertDays',
                    onChanged: (v) => setState(() => preAlertDays = v.toInt()),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              value: enabled,
              title: const Text('Autopay enabled'),
              onChanged: (v) => setState(() => enabled = v),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: saving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            setState(() => saving = true);
                            final result = AutopaySettingsResult(
                              autopayId: widget.initial.autopayId,
                              billerId: billerId,
                              type: type,
                              cap: cap,
                              preAlertDays: preAlertDays,
                              enabled: enabled,
                            );
                            Navigator.pop(context, result);
                          },
                    child: saving
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

Future<AutopaySettingsResult?> showAutopaySettingsSheet(
  BuildContext context, {
  required List<BillerDisplay> billers,
  required AutopaySettingsResult initial,
}) {
  return showModalBottomSheet<AutopaySettingsResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => AutopaySettingsSheet(billers: billers, initial: initial),
  );
}

