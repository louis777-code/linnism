import 'package:flutter/material.dart';

import 'linn_button.dart';
import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// Approve and reject actions with feedback for their shared review operation.
class LinnApprovalActions extends StatelessWidget {
  const LinnApprovalActions({
    required this.onApprove,
    required this.onReject,
    this.approveLabel = 'Approve',
    this.rejectLabel = 'Reject',
    this.state = LinnState.idle,
    this.message,
    this.style,
    super.key,
  });

  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final String approveLabel;
  final String rejectLabel;
  final LinnState state;
  final LinnThemeData? style;
  final String? message;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = LinnStyle.accent(context, state);
    final hasFeedback = state != LinnState.idle;
    final feedback = message ?? (hasFeedback ? state.label : null);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LinnButton(
              label: approveLabel,
              onPressed: state.isInteractive ? onApprove : null,
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: LinnStyle.accent(context, LinnState.error),
                minimumSize: const Size(48, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: LinnStyle.radius(context),
                ),
              ),
              onPressed: state.isInteractive ? onReject : null,
              child: Text(rejectLabel),
            ),
          ],
        ),
        if (feedback != null) ...[
          const SizedBox(height: 8),
          Semantics(
            liveRegion: true,
            value: hasFeedback && message != null ? state.label : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasFeedback) ...[
                  ExcludeSemantics(
                    child: LinnStateIndicator(state: state, color: accent),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    feedback,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: hasFeedback
                          ? accent
                          : theme.colorScheme.onSurfaceVariant,
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
