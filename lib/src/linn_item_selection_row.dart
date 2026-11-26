import 'package:flutter/material.dart';

import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// A pickable item with an optional description and leading icon.
///
/// The caller owns [selected], which remains visible during loading or errors.
class LinnItemSelectionRow extends StatelessWidget {
  const LinnItemSelectionRow({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.description,
    this.icon,
    this.state = LinnState.idle,
    this.style,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final String? description;
  final IconData? icon;
  final LinnState state;
  final LinnThemeData? style;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = state.isInteractive && onSelected != null;
    final displayState = state == LinnState.idle && !enabled
        ? LinnState.disabled
        : state;
    final accent = LinnStyle.accent(context, displayState);
    final feedback = switch (displayState) {
      LinnState.loading || LinnState.error || LinnState.success => true,
      _ => false,
    };

    return Semantics(
      value: displayState == LinnState.idle ? null : displayState.label,
      child: Material(
        color: selected
            ? Color.alphaBlend(accent.withValues(alpha: 0.10), scheme.surface)
            : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: LinnStyle.radius(context),
          side: BorderSide(
            color: selected || feedback ? accent : scheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          enabled: enabled,
          selected: selected,
          selectedColor: accent,
          onTap: enabled ? () => onSelected!(!selected) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          minLeadingWidth: 20,
          horizontalTitleGap: 10,
          leading: icon == null ? null : Icon(icon, size: 20),
          title: Text(label),
          subtitle: description == null ? null : Text(description!),
          trailing: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (feedback) ...[
                  LinnStateIndicator(state: displayState, color: accent),
                  const SizedBox(width: 6),
                ],
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 20,
                  color: selected ? accent : scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
