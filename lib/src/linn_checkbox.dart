import 'package:flutter/material.dart';

import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// A labeled, controlled checkbox with state feedback and a full-row tap target.
///
/// Update [value] in [onChanged]. Loading and disabled states block changes
/// without clearing the current selection.
class LinnCheckbox extends StatelessWidget {
  const LinnCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
    this.state = LinnState.idle,
    this.message,
    this.focusNode,
    this.style,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final LinnState state;
  final LinnThemeData? style;
  final String? message;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final settings = LinnThemeData.of(context);
    final accent = LinnStyle.accent(context, state);
    final enabled = state.isInteractive && onChanged != null;
    final hasFeedback = state == LinnState.error || state == LinnState.success;
    final customError =
        enabled && state == LinnState.error && settings.error != null;
    final hasCustomCheckColor = switch (state) {
      LinnState.error => settings.error != null || settings.onError != null,
      LinnState.success =>
        settings.success != null || settings.onSuccess != null,
      _ => settings.primary != null || settings.onPrimary != null,
    };
    final feedback = state == LinnState.error
        ? message ?? 'Please confirm this option.'
        : message;

    return Semantics(
      value: state == LinnState.idle && onChanged == null
          ? LinnState.disabled.label
          : state.label,
      liveRegion: hasFeedback,
      child: Material(
        color: Color.alphaBlend(
          accent.withValues(alpha: 0.035),
          scheme.surface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: LinnStyle.radius(context),
          side: BorderSide(
            color: hasFeedback
                ? accent.withValues(alpha: 0.6)
                : scheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: CheckboxListTile(
          value: value,
          onChanged: enabled ? (checked) => onChanged!(checked!) : null,
          focusNode: focusNode,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          activeColor: accent,
          fillColor: customError
              ? WidgetStateProperty.resolveWith(
                  (states) =>
                      states.contains(WidgetState.selected) ? accent : null,
                )
              : null,
          side: customError ? BorderSide(color: accent, width: 2) : null,
          checkColor: hasCustomCheckColor
              ? LinnStyle.onFill(settings, state)
              : scheme.brightness == Brightness.dark
              ? scheme.surface
              : Colors.white,
          isError: state == LinnState.error,
          checkboxShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          title: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: feedback == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    feedback,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: hasFeedback ? accent : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
          secondary: state == LinnState.loading
              ? LinnStateIndicator(state: state, color: accent)
              : null,
        ),
      ),
    );
  }
}
