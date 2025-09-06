import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../models/autopay_model.dart';
import '../widgets/autopay_settings_sheet.dart';

// Simple HTTP repository implementation (disabled in tests via override)
class AutopayRepositoryHttp implements AutopayRepository {
  final String baseUrl;
  AutopayRepositoryHttp({this.baseUrl = 'http://localhost:8000'});

  @override
  Future<String> add(AutopayInput input) async {
    final uri = Uri.parse('$baseUrl/autopay/add');
    final resp = await _httpPost(uri, input.toJson());
    return resp['autopay_id'] as String;
  }

  @override
  Future<void> delete(String autopayId) async {
    final uri = Uri.parse('$baseUrl/autopay/$autopayId');
    await _httpDelete(uri);
  }

  @override
  Future<List<AutopayConfig>> list() async {
    final uri = Uri.parse('$baseUrl/autopay');
    final data = await _httpGet(uri) as List<dynamic>;
    return data.map((e) => AutopayConfig.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> toggle(String autopayId, bool enabled) async {
    final uri = Uri.parse('$baseUrl/autopay/$autopayId/toggle');
    await _httpPost(uri, {'enabled': enabled});
  }

  @override
  Future<void> update(String autopayId, AutopayUpdate update) async {
    final uri = Uri.parse('$baseUrl/autopay/$autopayId');
    await _httpPatch(uri, update.toJson());
  }

  // --- HTTP helpers ---
  Future<dynamic> _httpGet(Uri uri) async {
    final res = await http.get(uri);
    if (res.statusCode >= 400) throw Exception('GET failed');
    return _decode(res.body);
  }

  Future<Map<String, dynamic>> _httpPost(Uri uri, Map<String, dynamic> body) async {
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'}, body: _encode(body));
    if (res.statusCode >= 400) throw Exception('POST failed');
    return _decode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _httpPatch(Uri uri, Map<String, dynamic> body) async {
    final res = await http.patch(uri,
        headers: {'Content-Type': 'application/json'}, body: _encode(body));
    if (res.statusCode >= 400) throw Exception('PATCH failed');
    return _decode(res.body) as Map<String, dynamic>;
  }

  Future<void> _httpDelete(Uri uri) async {
    final res = await http.delete(uri);
    if (res.statusCode >= 400) throw Exception('DELETE failed');
  }
}

dynamic _decode(String s) => s.isEmpty ? null : (const JsonDecoder()).convert(s);
String _encode(Map<String, dynamic> m) => (const JsonEncoder()).convert(m);

// In-memory fake repository for tests and offline dev
class AutopayRepositoryFake implements AutopayRepository {
  final List<AutopayConfig> _items;
  int _seq = 1;
  AutopayRepositoryFake([List<AutopayConfig>? seed]) : _items = List.of(seed ?? []);

  @override
  Future<String> add(AutopayInput input) async {
    final id = 'ap_${(_seq++).toString().padLeft(3, '0')}';
    _items.add(AutopayConfig(
      autopayId: id,
      billerId: input.billerId,
      type: input.type,
      cap: input.cap,
      preAlertDays: input.preAlertDays,
      enabled: input.enabled,
    ));
    return id;
  }

  @override
  Future<void> delete(String autopayId) async {
    _items.removeWhere((e) => e.autopayId == autopayId);
  }

  @override
  Future<List<AutopayConfig>> list() async {
    return List.unmodifiable(_items);
  }

  @override
  Future<void> toggle(String autopayId, bool enabled) async {
    final i = _items.indexWhere((e) => e.autopayId == autopayId);
    if (i >= 0) _items[i] = _items[i].copyWith(enabled: enabled);
  }

  @override
  Future<void> update(String autopayId, AutopayUpdate update) async {
    final i = _items.indexWhere((e) => e.autopayId == autopayId);
    if (i >= 0) {
      var e = _items[i];
      e = e.copyWith(
        type: update.type ?? e.type,
        cap: update.cap ?? e.cap,
        preAlertDays: update.preAlertDays ?? e.preAlertDays,
        enabled: update.enabled ?? e.enabled,
      );
      _items[i] = e;
    }
  }
}

final autopayRepositoryProvider = Provider<AutopayRepository>((ref) {
  return AutopayRepositoryHttp();
});

class AutopayController extends StateNotifier<AsyncValue<List<AutopayConfig>>> {
  AutopayController(this._read) : super(const AsyncValue.loading()) {
    load();
  }
  final Reader _read;

  AutopayRepository get _repo => _read(autopayRepositoryProvider);

  Future<void> load() async {
    try {
      final items = await _repo.list();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addOrUpdate({String? autopayId, required AutopayInput input, AutopayUpdate? update}) async {
    try {
      if (autopayId == null) {
        final id = await _repo.add(input);
        final newItem = AutopayConfig(
          autopayId: id,
          billerId: input.billerId,
          type: input.type,
          cap: input.cap,
          preAlertDays: input.preAlertDays,
          enabled: input.enabled,
        );
        final items = [...(state.value ?? []), newItem];
        state = AsyncValue.data(items);
      } else {
        if (update != null) {
          await _repo.update(autopayId, update);
          final items = (state.value ?? []).map((e) =>
              e.autopayId == autopayId
                  ? e.copyWith(
                      type: update.type ?? e.type,
                      cap: update.cap ?? e.cap,
                      preAlertDays: update.preAlertDays ?? e.preAlertDays,
                      enabled: update.enabled ?? e.enabled,
                    )
                  : e).toList();
          state = AsyncValue.data(items);
        }
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> toggle(String autopayId, bool enabled) async {
    try {
      await _repo.toggle(autopayId, enabled);
      final items = (state.value ?? [])
          .map((e) => e.autopayId == autopayId ? e.copyWith(enabled: enabled) : e)
          .toList();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> remove(String autopayId) async {
    try {
      await _repo.delete(autopayId);
      final items = (state.value ?? [])..removeWhere((e) => e.autopayId == autopayId);
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final autopayControllerProvider =
    StateNotifierProvider<AutopayController, AsyncValue<List<AutopayConfig>>>(
        (ref) => AutopayController(ref.read));

class AutopayManagerScreen extends ConsumerWidget {
  const AutopayManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(autopayControllerProvider);
    final currency = NumberFormat.currency(locale: 'en_GB', symbol: '£');

    final billersCatalog = <BillerDisplay>[
      const BillerDisplay(id: 'b123', name: 'British Gas', icon: Icons.bolt, dueLabel: 'Due 12th'),
      const BillerDisplay(id: 'b999', name: 'Thames Water', icon: Icons.water_drop, dueLabel: 'Due 25th'),
    ];

    Widget content = state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not load autopay configs. Tap to retry.'),
              action: SnackBarAction(label: 'Retry', onPressed: () => ref.read(autopayControllerProvider.notifier).load()),
            ),
          );
        });
        return Center(
          child: TextButton(
            onPressed: () => ref.read(autopayControllerProvider.notifier).load(),
            child: const Text('Retry'),
          ),
        );
      },
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.schedule, size: 72),
                  SizedBox(height: 16),
                  Text(
                    'No autopay set up yet. Enable it on a biller to get started.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 96),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final ap = items[index];
            final biller = billersCatalog.firstWhere(
              (b) => b.id == ap.billerId,
              orElse: () => const BillerDisplay(id: 'other', name: 'Unknown', icon: Icons.receipt_long, dueLabel: 'Due ?'),
            );
            final summary = StringBuffer(ap.type.label)
              ..write(ap.cap != null ? ' · Cap ${currency.format(ap.cap)}' : '')
              ..write(' · Pre-alert ${ap.preAlertDays}d');

            return ListTile(
              leading: Icon(biller.icon),
              title: Text(biller.name),
              subtitle: Text('${biller.dueLabel}  •  ${summary.toString()}'),
              trailing: Semantics(
                label: 'Autopay ${ap.enabled ? 'ON' : 'OFF'} for ${biller.name}',
                child: Switch.adaptive(
                  value: ap.enabled,
                  onChanged: (v) async {
                    await ref.read(autopayControllerProvider.notifier).toggle(ap.autopayId, v);
                    final text = 'Autopay ${v ? 'enabled' : 'disabled'}';
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
                  },
                ),
              ),
              onTap: () async {
                final result = await showAutopaySettingsSheet(
                  context,
                  billers: billersCatalog,
                  initial: AutopaySettingsResult(
                    autopayId: ap.autopayId,
                    billerId: ap.billerId,
                    type: ap.type,
                    cap: ap.cap,
                    preAlertDays: ap.preAlertDays,
                    enabled: ap.enabled,
                  ),
                );
                if (result != null) {
                  try {
                    await ref.read(autopayControllerProvider.notifier).addOrUpdate(
                          autopayId: ap.autopayId,
                          input: AutopayInput(
                            billerId: result.billerId,
                            type: result.type,
                            cap: result.cap,
                            preAlertDays: result.preAlertDays,
                            enabled: result.enabled,
                          ),
                          update: AutopayUpdate(
                            type: result.type,
                            cap: result.cap,
                            preAlertDays: result.preAlertDays,
                            enabled: result.enabled,
                          ),
                        );
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Autopay updated successfully')));
                  } catch (_) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update autopay')));
                  }
                }
              },
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Autopay Manager')),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: content,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showAutopaySettingsSheet(
            context,
            billers: billersCatalog,
            initial: const AutopaySettingsResult(
              autopayId: null,
              billerId: 'b123',
              type: AutopayType.minimum,
              cap: null,
              preAlertDays: 0,
              enabled: true,
            ),
          );
          if (result != null) {
            try {
              await ref.read(autopayControllerProvider.notifier).addOrUpdate(
                    input: AutopayInput(
                      billerId: result.billerId,
                      type: result.type,
                      cap: result.cap,
                      preAlertDays: result.preAlertDays,
                      enabled: result.enabled,
                    ),
                  );
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Autopay updated successfully')));
            } catch (_) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update autopay')));
            }
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('+ Add Autopay'),
      ),
    );
  }
}
