import 'package:flutter/material.dart';

import 'linn_button.dart';
import 'linn_popup_panel.dart';
import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// A confirmation dialog with a state-aware primary action.
///
/// [show] returns true on confirmation, false on Cancel, or null on dismissal.
/// Loading and disabled block confirmation. The optional Cancel action remains
/// available in both states.
class LinnDialog extends StatelessWidget {
  const LinnDialog({
    required this.title,
    this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel,
    this.showCancel = true,
    this.icon = Icons.rule_rounded,
    this.state = LinnState.idle,
    this.style,
    super.key,
  });

  final String title;
  final String? message;
  final String confirmLabel;
  final String? cancelLabel;
  final bool showCancel;
  final IconData icon;
  final LinnState state;
  final LinnThemeData? style;

  Future<bool?> show(BuildContext context) => showDialog<bool>(
    context: context,
    barrierColor: LinnStyle.popupBarrier(context),
    builder: (_) => this,
  );

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) => LinnPopupPanel(
    title: title,
    icon: icon,
    state: state,
    content: message == null ? null : Text(message!),
    actions: [
      if (showCancel)
        TextButton(
          style: LinnPopupPanel.secondaryButton(context),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelLabel ?? MaterialLocalizations.of(context).cancelButtonLabel,
          ),
        ),
      LinnButton(
        label: confirmLabel,
        state: state,
        minimumSize: const Size(104, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ],
  );
}
