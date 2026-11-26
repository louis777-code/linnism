import 'package:flutter/material.dart';

import 'linn_icon_button.dart';
import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// Increments or decrements a caller-owned quantity within its bounds.
class LinnQuantityStepper extends StatelessWidget {
  const LinnQuantityStepper({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max,
    this.label = 'Quantity',
    this.state = LinnState.idle,
    this.style,
    super.key,
  }) : assert(value >= min),
       assert(max == null || (max >= min && value <= max));

  final int value;
  final int min;
  final int? max;
  final String label;
  final ValueChanged<int>? onChanged;
  final LinnState state;
  final LinnThemeData? style;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = state.isInteractive && onChanged != null;
    final displayState = state == LinnState.idle && !enabled
        ? LinnState.disabled
        : state;
    final accent = LinnStyle.accent(context, displayState);
    final formatted = MaterialLocalizations.of(context).formatDecimal(value);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinnIconButton(
            icon: Icons.remove_rounded,
            label: 'Decrease quantity',
            onPressed: enabled && value > min
                ? () => onChanged!(value - 1)
                : null,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Semantics(
              value: displayState == LinnState.idle ? null : displayState.label,
              liveRegion: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(formatted, style: theme.textTheme.titleMedium),
                  if (displayState != LinnState.idle)
                    ExcludeSemantics(
                      child: LinnStateIndicator(
                        state: displayState,
                        color: accent,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          LinnIconButton(
            icon: Icons.add_rounded,
            label: 'Increase quantity',
            onPressed: enabled && (max == null || value < max!)
                ? () => onChanged!(value + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
