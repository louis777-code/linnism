import 'package:flutter/material.dart';

import 'linn_icon_button.dart';
import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// A calendar period label with previous and next actions.
///
/// The caller owns the date and formatting. A null callback disables its arrow.
class LinnCalendarHeader extends StatelessWidget {
  const LinnCalendarHeader({
    required this.title,
    this.subtitle,
    this.onPrevious,
    this.onNext,
    this.state = LinnState.idle,
    this.style,
    super.key,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final LinnState state;
  final LinnThemeData? style;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = LinnStyle.accent(context, state);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(
          color: state == LinnState.error ? accent : scheme.outlineVariant,
        ),
        borderRadius: LinnStyle.radius(context),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(title, style: theme.textTheme.titleSmall),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (state != LinnState.idle) ...[
            Semantics(
              label: state.label,
              liveRegion: true,
              child: ExcludeSemantics(
                child: LinnStateIndicator(state: state, color: accent),
              ),
            ),
            const SizedBox(width: 8),
          ],
          LinnIconButton(
            icon: Icons.chevron_left,
            label: 'Previous period',
            onPressed: state.isInteractive ? onPrevious : null,
          ),
          const SizedBox(width: 4),
          LinnIconButton(
            icon: Icons.chevron_right,
            label: 'Next period',
            onPressed: state.isInteractive ? onNext : null,
          ),
        ],
      ),
    );
  }
}
