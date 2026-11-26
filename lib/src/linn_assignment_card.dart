import 'package:flutter/material.dart';

import 'linn_state.dart';
import 'linn_status_badge.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// A card for a scheduled job, survey, or other assignment.
///
/// [statusLabel] describes the assignment. [state] controls feedback, and
/// [selected] marks the card independently. Supply [onPressed] when the card
/// should open or select an assignment.
class LinnAssignmentCard extends StatelessWidget {
  const LinnAssignmentCard({
    required this.title,
    this.subtitle,
    this.statusLabel,
    this.onPressed,
    this.selected = false,
    this.compact = false,
    this.state = LinnState.idle,
    this.style,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? statusLabel;
  final VoidCallback? onPressed;
  final bool selected;
  final bool compact;
  final LinnState state;
  final LinnThemeData? style;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = LinnStyle.accent(context, state);
    final enabled = state.isInteractive && onPressed != null;
    final showAccent =
        selected || state == LinnState.error || state == LinnState.success;
    final status =
        statusLabel ?? (state == LinnState.idle ? null : state.label);

    return Semantics(
      button: onPressed != null ? true : null,
      enabled: onPressed != null ? enabled : null,
      selected: selected || onPressed != null ? selected : null,
      child: Material(
        color: showAccent
            ? Color.alphaBlend(accent.withValues(alpha: 0.06), scheme.surface)
            : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: LinnStyle.radius(context),
          side: BorderSide(
            color: showAccent
                ? accent.withValues(alpha: 0.65)
                : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: Padding(
            padding: EdgeInsets.all(compact ? 8 : 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!compact) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.event_outlined, size: 20, color: accent),
                  ),
                  const SizedBox(width: 12),
                ],
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: state == LinnState.disabled
                              ? scheme.onSurfaceVariant
                              : scheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (status != null) ...[
                        const SizedBox(height: 10),
                        LinnStatusBadge(label: status, state: state),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
