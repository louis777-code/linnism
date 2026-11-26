import 'package:flutter/material.dart';

import 'linn_button.dart';
import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// Groups an optional Edit and Cancel with the primary Continue action.
class LinnWorkflowActions extends StatelessWidget {
  const LinnWorkflowActions({
    required this.onContinue,
    this.onEdit,
    this.onCancel,
    this.continueLabel = 'Continue',
    this.state = LinnState.idle,
    this.message,
    this.style,
    super.key,
  });

  final VoidCallback? onContinue;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final String continueLabel;
  final LinnState state;
  final LinnThemeData? style;
  final String? message;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final secondary = TextButton.styleFrom(
      foregroundColor: LinnStyle.accent(context, LinnState.idle),
      minimumSize: const Size(48, 48),
      shape: RoundedRectangleBorder(borderRadius: LinnStyle.radius(context)),
    );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (onCancel != null)
          TextButton(
            style: secondary,
            onPressed: state.isInteractive ? onCancel : null,
            child: const Text('Cancel'),
          ),
        if (onEdit != null)
          TextButton(
            style: secondary,
            onPressed: state.isInteractive ? onEdit : null,
            child: const Text('Edit'),
          ),
        LinnButton(
          label: continueLabel,
          onPressed: onContinue,
          state: state,
          message: message,
        ),
      ],
    );
  }
}
