import 'package:flutter/material.dart';

import 'linn_approval_actions.dart';
import 'linn_button.dart';
import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';
import 'linn_status_dot.dart';
import 'linn_team_picker.dart';

enum LinnReviewDecision { pending, approved, rejected }

/// Reviews a request, then offers team assignment once the app approves it.
class LinnApprovalAssignment extends StatelessWidget {
  const LinnApprovalAssignment({
    required this.decision,
    required this.teams,
    this.teamId,
    this.onApprove,
    this.onReject,
    this.onTeamChanged,
    this.onAssign,
    this.state = LinnState.idle,
    this.message,
    this.style,
    super.key,
  });

  final LinnReviewDecision decision;
  final Map<String, String> teams;
  final String? teamId;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final ValueChanged<String?>? onTeamChanged;
  final ValueChanged<String>? onAssign;
  final LinnState state;
  final LinnThemeData? style;
  final String? message;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final (label, tone) = switch (decision) {
      LinnReviewDecision.pending => ('Pending review', LinnStatusTone.warning),
      LinnReviewDecision.approved => ('Approved', LinnStatusTone.success),
      LinnReviewDecision.rejected => ('Rejected', LinnStatusTone.error),
    };
    final selected = teamId;
    final canAssign =
        selected != null && teams.containsKey(selected) && onAssign != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinnStatusDot(label: label, tone: tone, state: state),
        if (decision == LinnReviewDecision.pending) ...[
          const SizedBox(height: 12),
          LinnApprovalActions(
            onApprove: onApprove,
            onReject: onReject,
            state: state,
            message: message,
          ),
        ],
        if (decision == LinnReviewDecision.approved) ...[
          const SizedBox(height: 12),
          LinnTeamPicker(
            teams: teams,
            value: selected,
            onChanged: onTeamChanged,
            state: state,
            message: message,
          ),
          const SizedBox(height: 10),
          LinnButton(
            label: 'Assign',
            onPressed: canAssign ? () => onAssign!(selected) : null,
            state: state,
          ),
        ],
        if (decision == LinnReviewDecision.rejected && message != null) ...[
          const SizedBox(height: 8),
          Text(message!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}
