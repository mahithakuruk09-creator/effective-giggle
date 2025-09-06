import 'dart:convert';

enum AutopayType { minimum, full, fixed }

extension AutopayTypeX on AutopayType {
  String get label {
    switch (this) {
      case AutopayType.minimum:
        return 'Minimum';
      case AutopayType.full:
        return 'Full';
      case AutopayType.fixed:
        return 'Fixed';
    }
  }

  String get value => name; // for JSON

  static AutopayType from(String v) {
    switch (v) {
      case 'minimum':
        return AutopayType.minimum;
      case 'full':
        return AutopayType.full;
      case 'fixed':
        return AutopayType.fixed;
      default:
        return AutopayType.minimum;
    }
  }
}

class AutopayConfig {
  final String autopayId;
  final String billerId;
  final AutopayType type;
  final double? cap;
  final int preAlertDays; // 0-7
  final bool enabled;

  const AutopayConfig({
    required this.autopayId,
    required this.billerId,
    required this.type,
    required this.cap,
    required this.preAlertDays,
    required this.enabled,
  });

  AutopayConfig copyWith({
    String? autopayId,
    String? billerId,
    AutopayType? type,
    double? cap,
    int? preAlertDays,
    bool? enabled,
  }) => AutopayConfig(
        autopayId: autopayId ?? this.autopayId,
        billerId: billerId ?? this.billerId,
        type: type ?? this.type,
        cap: cap ?? this.cap,
        preAlertDays: preAlertDays ?? this.preAlertDays,
        enabled: enabled ?? this.enabled,
      );

  factory AutopayConfig.fromJson(Map<String, dynamic> json) => AutopayConfig(
        autopayId: json['autopay_id'] as String,
        billerId: json['biller_id'] as String,
        type: AutopayTypeX.from(json['type'] as String),
        cap: json['cap'] == null ? null : (json['cap'] as num).toDouble(),
        preAlertDays: json['pre_alert_days'] as int,
        enabled: json['enabled'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'autopay_id': autopayId,
        'biller_id': billerId,
        'type': type.value,
        'cap': cap,
        'pre_alert_days': preAlertDays,
        'enabled': enabled,
      };

  @override
  String toString() => jsonEncode(toJson());
}

class AutopayInput {
  final String billerId;
  final AutopayType type;
  final double? cap;
  final int preAlertDays;
  final bool enabled;

  const AutopayInput({
    required this.billerId,
    required this.type,
    required this.cap,
    required this.preAlertDays,
    required this.enabled,
  });

  Map<String, dynamic> toJson() => {
        'biller_id': billerId,
        'type': type.value,
        'cap': cap,
        'pre_alert_days': preAlertDays,
        'enabled': enabled,
      };
}

class AutopayUpdate {
  final AutopayType? type;
  final double? cap;
  final int? preAlertDays;
  final bool? enabled;

  const AutopayUpdate({this.type, this.cap, this.preAlertDays, this.enabled});

  Map<String, dynamic> toJson() => {
        if (type != null) 'type': type!.value,
        if (cap != null) 'cap': cap,
        if (preAlertDays != null) 'pre_alert_days': preAlertDays,
        if (enabled != null) 'enabled': enabled,
      };
}

// Lightweight repository API for Autopay
abstract class AutopayRepository {
  Future<List<AutopayConfig>> list();
  Future<String> add(AutopayInput input);
  Future<void> update(String autopayId, AutopayUpdate update);
  Future<void> delete(String autopayId);
  Future<void> toggle(String autopayId, bool enabled);
}

