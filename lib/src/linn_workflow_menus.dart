import 'package:flutter/material.dart';

import 'linn_dropdown.dart';
import 'linn_state.dart';
import 'linn_theme.dart';
import 'linn_status_dot.dart';

enum LinnScheduleStatus {
  scheduled('Scheduled', LinnStatusTone.info),
  done('Done', LinnStatusTone.success),
  canceled('Canceled', LinnStatusTone.error);

  const LinnScheduleStatus(this.label, this.tone);

  final String label;
  final LinnStatusTone tone;
}

enum LinnStockAvailability {
  inStock('In stock', LinnStatusTone.success),
  orderNeeded('Order needed', LinnStatusTone.warning);

  const LinnStockAvailability(this.label, this.tone);

  final String label;
  final LinnStatusTone tone;
}

/// Selects a survey's business status.
class LinnScheduleStatusMenu extends StatelessWidget {
  const LinnScheduleStatusMenu({
    required this.value,
    required this.onChanged,
    this.label = 'Schedule status',
    this.state = LinnState.idle,
    this.message,
    this.style,
    super.key,
  });

  final LinnScheduleStatus value;
  final ValueChanged<LinnScheduleStatus>? onChanged;
  final String label;
  final LinnState state;
  final LinnThemeData? style;
  final String? message;

  @override
  Widget build(BuildContext context) => LinnDropdown<LinnScheduleStatus>(
    label: label,
    items: LinnScheduleStatus.values,
    value: value,
    onChanged: onChanged == null
        ? null
        : (status) {
            if (status != null) onChanged!(status);
          },
    itemBuilder: (_, item) => LinnStatusDot(label: item.label, tone: item.tone),
    state: state,
    style: style,
    message: message,
  );
}

/// Selects whether a stock item is available or requires an order.
class LinnStockAvailabilityMenu extends StatelessWidget {
  const LinnStockAvailabilityMenu({
    required this.value,
    required this.onChanged,
    this.label = 'Stock availability',
    this.state = LinnState.idle,
    this.message,
    this.style,
    super.key,
  });

  final LinnStockAvailability value;
  final ValueChanged<LinnStockAvailability>? onChanged;
  final String label;
  final LinnState state;
  final LinnThemeData? style;
  final String? message;

  @override
  Widget build(BuildContext context) => LinnDropdown<LinnStockAvailability>(
    label: label,
    items: LinnStockAvailability.values,
    value: value,
    onChanged: onChanged == null
        ? null
        : (status) {
            if (status != null) onChanged!(status);
          },
    itemBuilder: (_, item) => LinnStatusDot(label: item.label, tone: item.tone),
    state: state,
    style: style,
    message: message,
  );
}
