import 'package:flutter/material.dart';

import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// A compact, non-interactive label for table rows, cards, and project statuses.
///
/// [label] describes the business status; [state] controls its feedback styling.
class LinnStatusBadge extends StatelessWidget {
  const LinnStatusBadge({
    required this.label,
    this.state = LinnState.idle,
    this.style,
    super.key,
  });

  final String label;
  final LinnState state;
  final LinnThemeData? style;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = LinnStyle.accent(context, state);
    return Semantics(
      container: true,
      label: label,
      value: state.label,
      liveRegion:
          state == LinnState.loading ||
          state == LinnState.success ||
          state == LinnState.error,
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minHeight: 34),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.09),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
            borderRadius: LinnStyle.radius(context),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state == LinnState.idle)
                Icon(Icons.circle, size: 8, color: accent)
              else
                LinnStateIndicator(state: state, color: accent),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
