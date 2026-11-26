import 'package:flutter/material.dart';

import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// The business status color displayed while the operation is idle.
enum LinnStatusTone { neutral, info, success, warning, error }

/// A compact status marker. Always supply a descriptive [label].
///
/// Set [showLabel] to false for a dot with a tooltip. [state] overrides the
/// color of [tone] when it carries operation feedback.
class LinnStatusDot extends StatelessWidget {
  const LinnStatusDot({
    required this.label,
    this.tone = LinnStatusTone.neutral,
    this.showLabel = true,
    this.state = LinnState.idle,
    this.style,
    super.key,
  });

  final String label;
  final LinnStatusTone tone;
  final bool showLabel;
  final LinnState state;
  final LinnThemeData? style;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final theme = Theme.of(context);
    final color = state != LinnState.idle
        ? LinnStyle.accent(context, state)
        : switch (tone) {
            LinnStatusTone.neutral => theme.colorScheme.onSurfaceVariant,
            LinnStatusTone.info => LinnStyle.accent(context, LinnState.idle),
            LinnStatusTone.success => LinnStyle.accent(
              context,
              LinnState.success,
            ),
            LinnStatusTone.warning => LinnStyle.warning(context),
            LinnStatusTone.error => LinnStyle.accent(context, LinnState.error),
          };
    final marker = state == LinnState.loading
        ? LinnStateIndicator(state: state, color: color)
        : Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          );
    return Semantics(
      container: true,
      label: label,
      value: state == LinnState.idle ? null : state.label,
      liveRegion: state.isInteractive && state != LinnState.idle,
      child: ExcludeSemantics(
        child: showLabel
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  marker,
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(label, style: theme.textTheme.labelLarge),
                  ),
                ],
              )
            : Tooltip(
                message: label,
                child: SizedBox.square(
                  dimension: 28,
                  child: Center(child: marker),
                ),
              ),
      ),
    );
  }
}
