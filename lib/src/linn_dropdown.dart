import 'package:flutter/material.dart';

import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// A labeled dropdown with explicit feedback and Flutter [Form] validation.
///
/// Supply distinct [items] and store selections through [onChanged]. Changes to
/// [value] update the displayed selection. [itemLabel] supports custom models.
/// Loading and disabled states preserve the selection and block the menu.
class LinnDropdown<T> extends StatelessWidget {
  const LinnDropdown({
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.state = LinnState.idle,
    this.message,
    this.hintText = 'Choose an option',
    this.itemLabel,
    this.itemBuilder,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.focusNode,
    this.style,
    this.contentPadding,
    this.textStyle,
    super.key,
  });

  final String label;
  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final LinnState state;
  final LinnThemeData? style;
  final String? message;
  final String hintText;
  final String Function(T item)? itemLabel;
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final FormFieldValidator<T>? validator;
  final AutovalidateMode autovalidateMode;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    assert(
      items.toSet().length == items.length,
      'Dropdown items must be distinct.',
    );
    assert(
      value == null || items.contains(value),
      'The selected value must be in items.',
    );
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final primary = LinnStyle.fill(LinnThemeData.of(context), LinnState.idle);
    final loading = state == LinnState.loading;
    final disabled =
        !loading &&
        (state == LinnState.disabled || onChanged == null || items.isEmpty);
    final enabled =
        state.isInteractive && onChanged != null && items.isNotEmpty;
    final accent = LinnStyle.accent(context, state);
    final hasFeedback = state == LinnState.error || state == LinnState.success;
    final borderColor = hasFeedback || loading ? accent : scheme.outline;
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: label,
          value: disabled
              ? LinnState.disabled.label
              : state == LinnState.idle
              ? null
              : state.label,
          child: DropdownButtonFormField<T>(
            initialValue: value,
            isExpanded: true,
            borderRadius: LinnStyle.popupRadius(context),
            elevation: 4,
            menuMaxHeight: 280,
            dropdownColor: scheme.surface,
            focusNode: focusNode,
            onChanged: enabled ? onChanged : null,
            validator: validator,
            autovalidateMode: autovalidateMode,
            forceErrorText: state == LinnState.error
                ? message ?? 'Please select an option.'
                : null,
            style:
                theme.textTheme.bodyMedium
                    ?.copyWith(
                      fontSize: 14,
                      height: 22 / 14,
                      color: scheme.onSurface,
                    )
                    .merge(textStyle) ??
                textStyle,
            hint: Text(hintText, overflow: TextOverflow.ellipsis),
            icon: loading
                ? LinnStateIndicator(state: state, color: accent)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasFeedback) ...[
                        LinnStateIndicator(state: state, color: accent),
                        const SizedBox(width: 8),
                      ],
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
            items: [
              for (final item in items)
                DropdownMenuItem<T>(
                  value: item,
                  child:
                      itemBuilder?.call(context, item) ??
                      Text(
                        itemLabel?.call(item) ?? item.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
            ],
            decoration: InputDecoration(
              filled: true,
              fillColor: disabled
                  ? scheme.onSurface.withValues(alpha: 0.04)
                  : scheme.surface,
              hoverColor: primary.withValues(alpha: 0.035),
              contentPadding:
                  contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
              border: border(borderColor),
              enabledBorder: border(borderColor),
              focusedBorder: border(hasFeedback ? accent : primary, 2),
              disabledBorder: border(
                loading ? accent : scheme.outline.withValues(alpha: 0.4),
              ),
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
            ),
          ),
        ),
      ],
    );
  }
}
