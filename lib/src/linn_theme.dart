import 'package:flutter/material.dart';

/// Appearance settings shared by Linn widgets and their descendants.
///
/// Register this extension with [applyTo] to use your app's Material colors,
/// or pass it to a Linn widget's `style` parameter to override specific values.
/// Unspecified values fall back to the surrounding Linn theme and its defaults.
@immutable
class LinnThemeData extends ThemeExtension<LinnThemeData> {
  const LinnThemeData({
    this.primary,
    this.onPrimary,
    this.success,
    this.onSuccess,
    this.error,
    this.onError,
    this.warning,
    this.disabled,
    this.borderRadius,
  });

  final Color? primary;
  final Color? onPrimary;
  final Color? success;
  final Color? onSuccess;
  final Color? error;
  final Color? onError;
  final Color? warning;
  final Color? disabled;
  final BorderRadius? borderRadius;

  /// Reads the Linn extension from the closest Flutter theme.
  static LinnThemeData of(BuildContext context) =>
      Theme.of(context).extension<LinnThemeData>() ?? const LinnThemeData();

  /// Installs Linn styling on an existing Flutter theme.
  ///
  /// Primary, error, and their foreground colors are seeded from the existing
  /// [ColorScheme]. The app's Flutter styles and other extensions are preserved.
  /// Call once for the light theme and again for the dark theme when available.
  ThemeData applyTo(ThemeData theme) {
    final scheme = theme.colorScheme;
    final defaults = LinnThemeData(
      primary: scheme.primary,
      onPrimary: scheme.onPrimary,
      error: scheme.error,
      onError: scheme.onError,
      disabled: scheme.onSurfaceVariant,
    );
    return _withLinnTheme(
      theme,
      defaults.merge(theme.extension<LinnThemeData>()).merge(this),
    );
  }

  /// Overlays each supplied value onto this theme.
  LinnThemeData merge(LinnThemeData? overrides) => overrides == null
      ? this
      : copyWith(
          primary: overrides.primary,
          onPrimary: overrides.onPrimary,
          success: overrides.success,
          onSuccess: overrides.onSuccess,
          error: overrides.error,
          onError: overrides.onError,
          warning: overrides.warning,
          disabled: overrides.disabled,
          borderRadius: overrides.borderRadius,
        );

  @override
  LinnThemeData copyWith({
    Color? primary,
    Color? onPrimary,
    Color? success,
    Color? onSuccess,
    Color? error,
    Color? onError,
    Color? warning,
    Color? disabled,
    BorderRadius? borderRadius,
  }) => LinnThemeData(
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    error: error ?? this.error,
    onError: onError ?? this.onError,
    warning: warning ?? this.warning,
    disabled: disabled ?? this.disabled,
    borderRadius: borderRadius ?? this.borderRadius,
  );

  @override
  LinnThemeData lerp(covariant LinnThemeData? other, double t) => other == null
      ? this
      : LinnThemeData(
          primary: Color.lerp(primary, other.primary, t),
          onPrimary: Color.lerp(onPrimary, other.onPrimary, t),
          success: Color.lerp(success, other.success, t),
          onSuccess: Color.lerp(onSuccess, other.onSuccess, t),
          error: Color.lerp(error, other.error, t),
          onError: Color.lerp(onError, other.onError, t),
          warning: Color.lerp(warning, other.warning, t),
          disabled: Color.lerp(disabled, other.disabled, t),
          borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t),
        );

  static ThemeData _withLinnTheme(ThemeData theme, LinnThemeData data) =>
      theme.copyWith(
        extensions: [
          ...theme.extensions.values.where(
            (extension) => extension is! LinnThemeData,
          ),
          data,
        ],
      );
}

ThemeData linnThemeWithOverrides(ThemeData theme, LinnThemeData? overrides) =>
    overrides == null
    ? theme
    : LinnThemeData._withLinnTheme(
        theme,
        (theme.extension<LinnThemeData>() ?? const LinnThemeData()).merge(
          overrides,
        ),
      );
