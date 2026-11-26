import 'package:flutter/material.dart';

import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// A labeled Solar input supporting both explicit states and Flutter forms.
///
/// Pass [state] and [message] to display an external validation error, or use
/// [validator] inside a [Form]. Loading preserves the value and prevents edits.
class LinnTextField extends StatelessWidget {
  const LinnTextField({
    required this.label,
    this.state = LinnState.idle,
    this.message,
    this.hintText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.style,
    this.contentPadding,
    this.textStyle,
    super.key,
  }) : assert(
         controller == null || initialValue == null,
         'Provide either controller or initialValue, not both.',
       );

  final String label;
  final LinnState state;
  final LinnThemeData? style;
  final String? message;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode autovalidateMode;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final primary = LinnStyle.fill(LinnThemeData.of(context), LinnState.idle);
    final accent = LinnStyle.accent(context, state);
    final hasFeedback = state == LinnState.success || state == LinnState.error;
    final feedbackIcon = hasFeedback || state == LinnState.loading
        ? Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: LinnStateIndicator(state: state, color: accent),
            ),
          )
        : null;
    final trailingIcon = state.isInteractive ? suffixIcon : null;
    final borderColor = hasFeedback ? accent : scheme.outline;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: LinnStyle.radius(context),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: label,
          value: state == LinnState.idle ? null : state.label,
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            focusNode: focusNode,
            enabled: state != LinnState.disabled,
            readOnly: state == LinnState.loading,
            onChanged: onChanged,
            onFieldSubmitted: onSubmitted,
            validator: validator,
            autovalidateMode: autovalidateMode,
            forceErrorText: state == LinnState.error
                ? message ?? 'Please check this field.'
                : null,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            cursorColor: primary,
            style:
                theme.textTheme.bodyMedium
                    ?.copyWith(
                      fontSize: 14,
                      height: 22 / 14,
                      color: state == LinnState.error ? accent : null,
                    )
                    .merge(textStyle) ??
                textStyle,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: scheme.onSurfaceVariant),
              filled: true,
              fillColor: state == LinnState.disabled
                  ? scheme.onSurface.withValues(alpha: 0.04)
                  : scheme.surface,
              hoverColor: primary.withValues(alpha: 0.035),
              contentPadding:
                  contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
              border: border(borderColor),
              enabledBorder: border(borderColor),
              focusedBorder: border(hasFeedback ? accent : primary, 2),
              disabledBorder: border(scheme.outline.withValues(alpha: 0.4)),
              errorBorder: border(LinnStyle.accent(context, LinnState.error)),
              focusedErrorBorder: border(
                LinnStyle.accent(context, LinnState.error),
                2,
              ),
              errorStyle: TextStyle(
                color: LinnStyle.accent(context, LinnState.error),
              ),
              errorMaxLines: 4,
              helperText: state == LinnState.error ? null : message,
              helperStyle: TextStyle(
                color: hasFeedback ? accent : scheme.onSurfaceVariant,
              ),
              helperMaxLines: 4,
              prefixIcon: prefixIcon,
              suffixIcon: feedbackIcon != null && trailingIcon != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [trailingIcon, feedbackIcon],
                    )
                  : trailingIcon ?? feedbackIcon,
            ),
          ),
        ),
      ],
    );
  }
}
