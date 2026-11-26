import 'package:flutter/material.dart';

import 'linn_state.dart';
import 'linn_theme.dart';

/// Shared implementation details. Colors are taken from the SG Solar file.
abstract final class LinnStyle {
  static const defaultRadius = BorderRadius.all(Radius.circular(8));
  static const _primary = Color(0xFF306CD8);
  static const _error = Color(0xFFD32F2F);
  static const _success = Color(0xFF15803D);

  // Keep this scope mounted so updating `style` preserves control state and
  // Flutter routes can capture the same overrides as the originating widget.
  static Widget scope(
    BuildContext context,
    LinnThemeData? style,
    WidgetBuilder builder,
  ) => Theme(
    data: linnThemeWithOverrides(Theme.of(context), style),
    child: Builder(builder: builder),
  );

  static BorderRadius radius(BuildContext context) =>
      LinnThemeData.of(context).borderRadius ?? defaultRadius;

  static BorderRadius popupRadius(BuildContext context) =>
      LinnThemeData.of(context).borderRadius ??
      const BorderRadius.all(Radius.circular(16));

  static RoundedRectangleBorder popupShape(BuildContext context) =>
      RoundedRectangleBorder(
        borderRadius: popupRadius(context),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      );

  static Color popupBarrier(BuildContext context) {
    final theme = Theme.of(context);
    return theme.dialogTheme.barrierColor ??
        (theme.brightness == Brightness.dark
            ? const Color(0xAD000000)
            : const Color(0x8A101828));
  }

  static Color accent(BuildContext context, LinnState state) {
    final theme = Theme.of(context);
    final style = LinnThemeData.of(context);
    final dark = theme.brightness == Brightness.dark;
    return switch (state) {
      LinnState.error =>
        style.error ?? (dark ? const Color(0xFFFF9995) : _error),
      LinnState.success =>
        style.success ?? (dark ? const Color(0xFF77D89C) : _success),
      LinnState.disabled =>
        style.disabled ?? theme.colorScheme.onSurfaceVariant,
      _ => style.primary ?? (dark ? const Color(0xFF9DBCFF) : _primary),
    };
  }

  static Color warning(BuildContext context) =>
      LinnThemeData.of(context).warning ??
      (Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFFFCB6B)
          : const Color(0xFF946100));

  static Color fill(LinnThemeData style, LinnState state) => switch (state) {
    LinnState.error => style.error ?? _error,
    LinnState.success => style.success ?? _success,
    _ => style.primary ?? _primary,
  };

  static Color onFill(LinnThemeData style, LinnState state) {
    final (foreground, background) = switch (state) {
      LinnState.error => (style.onError, style.error),
      LinnState.success => (style.onSuccess, style.success),
      _ => (style.onPrimary, style.primary),
    };
    if (foreground != null) return foreground;
    return background != null &&
            ThemeData.estimateBrightnessForColor(background) == Brightness.light
        ? Colors.black
        : Colors.white;
  }

  static Color activeFill(LinnThemeData style, {required bool pressed}) {
    final primary = style.primary;
    if (primary == null) {
      return pressed ? const Color(0xFF2559B9) : const Color(0xFF1E4895);
    }
    return Color.alphaBlend(
      onFill(style, LinnState.idle).withValues(alpha: pressed ? 0.16 : 0.08),
      primary,
    );
  }
}

/// A tinted tile for the decorative icon on feedback surfaces.
class LinnFeedbackIcon extends StatelessWidget {
  const LinnFeedbackIcon({
    required this.state,
    required this.color,
    this.icon,
    this.size = 36,
    this.borderRadius,
    super.key,
  });

  final LinnState state;
  final Color color;
  final IconData? icon;
  final double size;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: borderRadius ?? LinnStyle.radius(context),
      ),
      child: icon != null && state == LinnState.idle
          ? Icon(icon, size: 20, color: color)
          : LinnStateIndicator(state: state, color: color),
    ),
  );
}

/// A shared indicator used internally by the Solar components.
class LinnStateIndicator extends StatelessWidget {
  const LinnStateIndicator({
    required this.state,
    required this.color,
    super.key,
  });

  final LinnState state;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (state == LinnState.loading) {
      return SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
          semanticsLabel: 'Loading',
        ),
      );
    }
    return Icon(
      switch (state) {
        LinnState.success => Icons.check_circle_outline_rounded,
        LinnState.error => Icons.error_outline_rounded,
        LinnState.disabled => Icons.block_rounded,
        _ => Icons.info_outline_rounded,
      },
      size: 20,
      color: color,
    );
  }
}
