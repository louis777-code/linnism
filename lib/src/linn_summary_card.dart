import 'package:flutter/material.dart';

import 'linn_state.dart';
import 'linn_status_badge.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// A dashboard metric with a label, value, and optional details.
///
/// Pass a previous [value] to keep it visible while a refresh is in progress.
class LinnSummaryCard extends StatelessWidget {
  const LinnSummaryCard({
    required this.label,
    this.value,
    this.details,
    this.icon,
    this.state = LinnState.idle,
    this.style,
    super.key,
  });

  final String label;
  final String? value;
  final String? details;
  final IconData? icon;
  final LinnState state;
  final LinnThemeData? style;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = LinnStyle.accent(context, state);
    final feedback = switch (state) {
      LinnState.idle => null,
      LinnState.loading => 'Updating',
      LinnState.success => 'Updated',
      LinnState.error => 'Needs attention',
      LinnState.disabled => 'Unavailable',
    };

    return Semantics(
      container: true,
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: LinnStyle.radius(context),
          side: BorderSide(
            color: state == LinnState.error ? accent : scheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: accent),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value ?? '—',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (details != null) ...[
                const SizedBox(height: 4),
                Text(
                  details!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (feedback != null) ...[
                const SizedBox(height: 10),
                LinnStatusBadge(label: feedback, state: state),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
