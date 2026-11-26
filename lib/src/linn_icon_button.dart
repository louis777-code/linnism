import 'package:flutter/material.dart';

import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// A compact icon action. [label] supplies its tooltip and accessible name.
class LinnIconButton extends StatelessWidget {
  const LinnIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.state = LinnState.idle,
    this.style,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final LinnState state;
  final LinnThemeData? style;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loading = state == LinnState.loading;
    final enabled = state.isInteractive && onPressed != null;
    final displayState = enabled || loading ? state : LinnState.disabled;
    final accent = LinnStyle.accent(context, displayState);
    final background = Color.alphaBlend(
      accent.withValues(alpha: enabled || loading ? 0.12 : 0.06),
      scheme.surface,
    );
    final indicator = switch (displayState) {
      LinnState.loading || LinnState.error || LinnState.success =>
        LinnStateIndicator(state: displayState, color: accent),
      _ => Icon(icon),
    };

    return Semantics(
      value: displayState == LinnState.idle ? null : displayState.label,
      liveRegion:
          displayState == LinnState.error || displayState == LinnState.success,
      child: IconButton.filledTonal(
        tooltip: label,
        onPressed: enabled ? onPressed : null,
        icon: indicator,
        style: IconButton.styleFrom(
          foregroundColor: accent,
          disabledForegroundColor: accent,
          backgroundColor: background,
          disabledBackgroundColor: background,
          minimumSize: const Size.square(48),
          shape: RoundedRectangleBorder(
            borderRadius: LinnStyle.radius(context),
          ),
        ),
      ),
    );
  }
}
