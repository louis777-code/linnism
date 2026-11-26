import 'package:flutter/material.dart';

import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// A calendar slot with a time and an action supplied by the caller.
class LinnScheduleSlot extends StatelessWidget {
  const LinnScheduleSlot({
    required this.timeLabel,
    required this.onPressed,
    this.label = 'Schedule survey',
    this.state = LinnState.idle,
    this.style,
    super.key,
  });

  final String timeLabel;
  final String label;
  final VoidCallback? onPressed;
  final LinnState state;
  final LinnThemeData? style;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = state.isInteractive && onPressed != null;
    final displayState = state == LinnState.idle && !enabled
        ? LinnState.disabled
        : state;
    final accent = LinnStyle.accent(context, displayState);

    return Semantics(
      value: displayState == LinnState.idle ? null : displayState.label,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          disabledForegroundColor: accent,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          side: BorderSide(color: accent.withValues(alpha: 0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: LinnStyle.radius(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (displayState == LinnState.idle)
              const Icon(Icons.event_available_outlined, size: 20)
            else
              ExcludeSemantics(
                child: LinnStateIndicator(state: displayState, color: accent),
              ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label),
                  Text(
                    timeLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
