import 'package:flutter/material.dart';

import 'linn_button.dart';
import 'linn_popup_panel.dart';
import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// Feedback with a state indicator and optional action and dismissal.
///
/// Place it inline or call [show] to present it as a modal alert.
class LinnAlert extends StatelessWidget {
  const LinnAlert({
    required this.title,
    this.message,
    this.state = LinnState.idle,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.style,
    super.key,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'Provide actionLabel and onAction together.',
       );

  final String title;
  final String? message;
  final LinnState state;
  final LinnThemeData? style;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  /// Opens a modal alert. A chosen action runs after the dialog closes.
  /// Closing without choosing the action calls [onDismiss] when enabled.
  Future<void> show(BuildContext context) async {
    final actionSelected = await showDialog<bool>(
      context: context,
      barrierColor: LinnStyle.popupBarrier(context),
      builder: (context) => LinnStyle.scope(context, style, _buildPopup),
    );
    if (!context.mounted) return;
    if (actionSelected == true) {
      onAction?.call();
    } else if (state != LinnState.disabled) {
      onDismiss?.call();
    }
  }

  Widget _buildPopup(BuildContext context) => LinnPopupPanel(
    title: title,
    state: state,
    content: message == null ? null : Text(message!),
    actions: [
      TextButton(
        style: LinnPopupPanel.secondaryButton(context),
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(MaterialLocalizations.of(context).closeButtonLabel),
      ),
      if (onAction != null)
        LinnButton(
          label: actionLabel!,
          state: state,
          minimumSize: const Size(96, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          onPressed: () => Navigator.of(context).pop(true),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = LinnStyle.accent(context, state);
    final radius = LinnStyle.radius(context);

    return Semantics(
      container: true,
      liveRegion: state != LinnState.idle && state != LinnState.disabled,
      value: state.label,
      child: Material(
        color: Color.alphaBlend(
          accent.withValues(alpha: 0.045),
          scheme.surface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: Color.alphaBlend(
              accent.withValues(alpha: 0.22),
              scheme.outlineVariant,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinnFeedbackIcon(state: state, color: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (onDismiss != null)
                          IconButton(
                            tooltip: 'Dismiss alert',
                            onPressed: state == LinnState.disabled
                                ? null
                                : onDismiss,
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: scheme.onSurfaceVariant,
                            style: IconButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: radius,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        message!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.6,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (onAction != null) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: state.isInteractive ? onAction : null,
                        style: TextButton.styleFrom(
                          foregroundColor: accent,
                          backgroundColor: accent.withValues(alpha: 0.10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: radius),
                        ),
                        child: Text(actionLabel!),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
