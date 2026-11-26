import 'package:flutter/material.dart';

import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// Brief feedback with an optional action such as Retry or Undo.
///
/// Call [show] to present it through the nearest [ScaffoldMessenger]. The
/// widget also renders inline for previews.
class LinnSnackbar extends StatelessWidget {
  const LinnSnackbar({
    required this.message,
    this.state = LinnState.idle,
    this.actionLabel,
    this.onAction,
    this.style,
    super.key,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'Provide actionLabel and onAction together.',
       );

  final String message;
  final LinnState state;
  final String? actionLabel;
  final VoidCallback? onAction;
  final LinnThemeData? style;

  ({Color background, Color foreground, RoundedRectangleBorder shape})
  _appearance(BuildContext context) {
    final settings = LinnThemeData.of(context).merge(style);
    final background = switch (state) {
      LinnState.error || LinnState.success => LinnStyle.fill(settings, state),
      LinnState.disabled => settings.disabled ?? const Color(0xFF505866),
      _ => settings.primary ?? const Color(0xFF273650),
    };
    return (
      background: background,
      foreground: state == LinnState.disabled
          ? ThemeData.estimateBrightnessForColor(background) == Brightness.light
                ? Colors.black
                : Colors.white
          : LinnStyle.onFill(settings, state),
      shape: RoundedRectangleBorder(
        borderRadius: settings.borderRadius ?? LinnStyle.defaultRadius,
      ),
    );
  }

  bool get _hasAction => state.isInteractive && onAction != null;

  /// Displays this message with the standard snackbar queue and dismissal.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final appearance = _appearance(context);
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _content(
          context,
          appearance.foreground,
          appearance.shape.borderRadius,
        ),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: appearance.background,
        shape: appearance.shape,
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        showCloseIcon: true,
        closeIconColor: appearance.foreground,
        action: _hasAction
            ? SnackBarAction(
                label: actionLabel!,
                textColor: appearance.foreground,
                onPressed: onAction!,
              )
            : null,
      ),
    );
  }

  Widget _content(
    BuildContext context,
    Color foreground,
    BorderRadiusGeometry radius,
  ) => Semantics(
    value: state == LinnState.idle ? null : state.label,
    child: Row(
      children: [
        LinnFeedbackIcon(
          state: state,
          color: foreground,
          size: 34,
          borderRadius: radius,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: foreground,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final appearance = _appearance(context);
    return Material(
      color: appearance.background,
      shape: appearance.shape,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _content(
              context,
              appearance.foreground,
              appearance.shape.borderRadius,
            ),
            if (_hasAction)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: appearance.foreground,
                  shape: appearance.shape,
                ),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
          ],
        ),
      ),
    );
  }
}
