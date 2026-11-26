import 'package:flutter/material.dart';

import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// A toggle for a filter or category. The app owns [selected].
class LinnFilterChip extends StatelessWidget {
  const LinnFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.state = LinnState.idle,
    this.style,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final LinnState state;
  final LinnThemeData? style;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = state.isInteractive && onSelected != null;
    final displayState = !enabled && state == LinnState.idle
        ? LinnState.disabled
        : state;
    final accent = LinnStyle.accent(context, displayState);
    final tint = Color.alphaBlend(
      accent.withValues(alpha: 0.12),
      scheme.surface,
    );
    final hasIndicator =
        displayState == LinnState.loading ||
        displayState == LinnState.success ||
        displayState == LinnState.error;

    return Semantics(
      value: displayState == LinnState.idle ? null : displayState.label,
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: enabled ? onSelected : null,
        avatar: hasIndicator
            ? ExcludeSemantics(
                child: LinnStateIndicator(state: displayState, color: accent),
              )
            : null,
        showCheckmark: !hasIndicator,
        backgroundColor: scheme.surface,
        selectedColor: tint,
        disabledColor: selected ? tint : scheme.surface,
        labelStyle: TextStyle(
          color: selected || !enabled ? accent : scheme.onSurface,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
        checkmarkColor: accent,
        side: BorderSide(
          color: selected || hasIndicator ? accent : scheme.outline,
        ),
        shape: RoundedRectangleBorder(borderRadius: LinnStyle.radius(context)),
      ),
    );
  }
}
