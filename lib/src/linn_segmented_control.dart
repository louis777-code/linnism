import 'package:flutter/material.dart';

import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// A single-choice control for a short list of related options.
///
/// [options] maps values to labels in display order. Update [value] through
/// [onChanged]. Loading and disabled preserve the current selection.
class LinnSegmentedControl<T extends Object> extends StatelessWidget {
  const LinnSegmentedControl({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.state = LinnState.idle,
    this.message,
    this.direction = Axis.horizontal,
    this.style,
    super.key,
  });

  final String label;
  final Map<T, String> options;
  final T value;
  final ValueChanged<T>? onChanged;
  final LinnState state;
  final LinnThemeData? style;
  final String? message;
  final Axis direction;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    assert(
      options.containsKey(value),
      'The selected value must be in options.',
    );
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = state.isInteractive && onChanged != null;
    final displayState = state == LinnState.idle && !enabled
        ? LinnState.disabled
        : state;
    final accent = LinnStyle.accent(context, displayState);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(child: Text(label, style: theme.textTheme.labelLarge)),
        const SizedBox(height: 6),
        Semantics(
          container: true,
          explicitChildNodes: true,
          label: label,
          child: SegmentedButton<T>(
            direction: direction,
            showSelectedIcon: false,
            segments: [
              for (final option in options.entries)
                ButtonSegment(
                  value: option.key,
                  label: Text(option.value, textAlign: TextAlign.center),
                ),
            ],
            selected: {value},
            onSelectionChanged: enabled
                ? (selection) {
                    final next = selection.single;
                    if (next != value) onChanged!(next);
                  }
                : null,
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: LinnStyle.radius(context)),
              ),
              side: WidgetStatePropertyAll(
                BorderSide(
                  color: state == LinnState.idle ? scheme.outline : accent,
                ),
              ),
              minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return accent;
                return enabled ? scheme.onSurface : scheme.onSurfaceVariant;
              }),
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? Color.alphaBlend(
                        accent.withValues(alpha: 0.13),
                        scheme.surface,
                      )
                    : scheme.surface,
              ),
              textStyle: WidgetStateProperty.resolveWith(
                (states) => theme.textTheme.labelLarge?.copyWith(
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        if (displayState != LinnState.idle || message != null) ...[
          const SizedBox(height: 4),
          Semantics(
            liveRegion: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (displayState != LinnState.idle) ...[
                  ExcludeSemantics(
                    child: LinnStateIndicator(
                      state: displayState,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    message ?? displayState.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: displayState == LinnState.idle
                          ? scheme.onSurfaceVariant
                          : accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
