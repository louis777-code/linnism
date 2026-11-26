import 'package:flutter/material.dart';

import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// A Solar action button whose appearance and interactivity follow [state].
///
/// Loading and disabled states block taps. Error and success states remain
/// actionable, so the caller can provide retry or continue behavior.
class LinnButton extends StatelessWidget {
  const LinnButton({
    required this.label,
    required this.onPressed,
    this.state = LinnState.idle,
    this.icon,
    this.message,
    this.style,
    this.padding,
    this.minimumSize,
    this.textStyle,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final LinnState state;
  final LinnThemeData? style;
  final EdgeInsetsGeometry? padding;
  final Size? minimumSize;
  final TextStyle? textStyle;
  final Widget? icon;

  /// Optional feedback displayed below the button, including error details.
  final String? message;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final settings = LinnThemeData.of(context);
    final disabled =
        state == LinnState.disabled ||
        (onPressed == null && state != LinnState.loading);
    final muted = settings.disabled ?? scheme.onSurface;
    final background = disabled
        ? muted.withValues(alpha: 0.10)
        : LinnStyle.fill(settings, state);
    final foreground = disabled
        ? muted.withValues(alpha: 0.45)
        : LinnStyle.onFill(settings, state);
    final indicator = switch (state) {
      LinnState.loading ||
      LinnState.success ||
      LinnState.error => LinnStateIndicator(state: state, color: foreground),
      _ => icon,
    };

    final button = Semantics(
      value: disabled ? LinnState.disabled.label : state.label,
      liveRegion: state == LinnState.success || state == LinnState.error,
      child: FilledButton(
        onPressed: state.isInteractive ? onPressed : null,
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(
            minimumSize ?? const Size(135, 48),
          ),
          padding: WidgetStatePropertyAll(
            padding ?? const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: LinnStyle.radius(context)),
          ),
          textStyle: WidgetStatePropertyAll(
            theme.textTheme.labelLarge
                    ?.copyWith(
                      fontSize: 14,
                      height: 22 / 14,
                      fontWeight: FontWeight.w500,
                    )
                    .merge(textStyle) ??
                textStyle,
          ),
          foregroundColor: WidgetStatePropertyAll(foreground),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (disabled || !state.isInteractive) return background;
            if (state == LinnState.idle) {
              if (states.contains(WidgetState.pressed)) {
                return LinnStyle.activeFill(settings, pressed: true);
              }
              if (states.contains(WidgetState.hovered)) {
                return LinnStyle.activeFill(settings, pressed: false);
              }
            }
            return background;
          }),
          overlayColor: WidgetStateProperty.resolveWith(
            (states) => foreground.withValues(
              alpha: states.contains(WidgetState.focused) ? 0.20 : 0.06,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (indicator != null) ...[indicator, const SizedBox(width: 8)],
            Flexible(child: Text(label, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );

    if (message == null) return button;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        button,
        const SizedBox(height: 8),
        Semantics(
          liveRegion: true,
          child: Text(
            message!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: LinnStyle.accent(context, state),
            ),
          ),
        ),
      ],
    );
  }
}
