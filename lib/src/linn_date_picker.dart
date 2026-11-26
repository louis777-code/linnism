import 'package:flutter/material.dart';

import 'linn_popup_panel.dart';
import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// A single-date field that opens a calendar and reports the confirmed date.
///
/// The caller owns [value]. Use [selectableDayPredicate] to make dates
/// unavailable, and [message] to explain a validation error.
class LinnDatePicker extends StatefulWidget {
  const LinnDatePicker({
    required this.label,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.value,
    this.selectableDayPredicate,
    this.hintText = 'Choose a date',
    this.state = LinnState.idle,
    this.message,
    this.style,
    this.contentPadding,
    this.textStyle,
    super.key,
  });

  final String label;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime>? onChanged;
  final DateTime? value;
  final SelectableDayPredicate? selectableDayPredicate;
  final String hintText;
  final LinnState state;
  final LinnThemeData? style;
  final String? message;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;

  @override
  State<LinnDatePicker> createState() => _LinnDatePickerState();
}

class _LinnDatePickerState extends State<LinnDatePicker> {
  bool _opening = false;
  bool _focused = false;

  bool get _enabled => widget.state.isInteractive && widget.onChanged != null;

  bool _canSelect(DateTime date) =>
      !date.isBefore(DateUtils.dateOnly(widget.firstDate)) &&
      !date.isAfter(DateUtils.dateOnly(widget.lastDate)) &&
      (widget.selectableDayPredicate?.call(date) ?? true);

  Future<void> _pick(BuildContext context) async {
    if (_opening || !_enabled) return;
    _opening = true;
    try {
      final value = widget.value;
      final initial = value == null ? null : DateUtils.dateOnly(value);
      final date = await showDatePicker(
        context: context,
        barrierColor: LinnStyle.popupBarrier(context),
        initialDate: initial != null && _canSelect(initial) ? initial : null,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        selectableDayPredicate: widget.selectableDayPredicate,
        helpText: widget.label,
        builder: (context, child) {
          final theme = Theme.of(context);
          final settings = LinnThemeData.of(context);
          final picker = DatePickerTheme.of(context);
          final scheme = theme.colorScheme.copyWith(
            primary: settings.primary,
            onPrimary: settings.primary == null && settings.onPrimary == null
                ? null
                : LinnStyle.onFill(settings, LinnState.idle),
            error: settings.error,
            onError: settings.error == null && settings.onError == null
                ? null
                : LinnStyle.onFill(settings, LinnState.error),
          );
          final controlShape = RoundedRectangleBorder(
            borderRadius: LinnStyle.radius(context),
          );
          return Theme(
            data: theme.copyWith(colorScheme: scheme),
            child: DatePickerTheme(
              data: picker.copyWith(
                shape: settings.borderRadius != null
                    ? LinnStyle.popupShape(context)
                    : picker.shape ?? LinnStyle.popupShape(context),
                elevation: picker.elevation ?? 10,
                backgroundColor: picker.backgroundColor ?? scheme.surface,
                surfaceTintColor: picker.surfaceTintColor ?? Colors.transparent,
                headerBackgroundColor:
                    picker.headerBackgroundColor ?? scheme.surfaceContainerLow,
                headerForegroundColor:
                    picker.headerForegroundColor ?? scheme.onSurface,
                headerHeadlineStyle:
                    picker.headerHeadlineStyle ??
                    theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                dividerColor: picker.dividerColor ?? scheme.outlineVariant,
                dayShape:
                    picker.dayShape ?? WidgetStatePropertyAll(controlShape),
                yearShape:
                    picker.yearShape ?? WidgetStatePropertyAll(controlShape),
                cancelButtonStyle:
                    picker.cancelButtonStyle ??
                    LinnPopupPanel.secondaryButton(context),
                confirmButtonStyle:
                    picker.confirmButtonStyle ??
                    TextButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      minimumSize: const Size(72, 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: controlShape,
                    ),
              ),
              child: child!,
            ),
          );
        },
      );
      if (mounted && date != null && _enabled && _canSelect(date)) {
        widget.onChanged!(date);
      }
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) =>
      LinnStyle.scope(context, widget.style, _build);

  Widget _build(BuildContext context) {
    assert(
      !DateUtils.dateOnly(
        widget.lastDate,
      ).isBefore(DateUtils.dateOnly(widget.firstDate)),
      'lastDate must be on or after firstDate.',
    );
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final displayState = !_enabled && widget.state == LinnState.idle
        ? LinnState.disabled
        : widget.state;
    final accent = LinnStyle.accent(context, displayState);
    final hasError = displayState == LinnState.error;
    final disabled = displayState == LinnState.disabled;
    final value = widget.value;
    final dateText = value == null
        ? widget.hintText
        : MaterialLocalizations.of(context).formatMediumDate(value);
    final feedback =
        widget.message ?? (hasError ? 'Choose an available date.' : null);
    final borderColor = switch (displayState) {
      LinnState.idle => scheme.outline,
      LinnState.disabled => scheme.outline.withValues(alpha: 0.45),
      _ => accent,
    };
    final border = OutlineInputBorder(
      borderRadius: LinnStyle.radius(context),
      borderSide: BorderSide(
        color: _focused && _enabled ? accent : borderColor,
        width: _focused && _enabled ? 2 : 1,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Text(widget.label, style: theme.textTheme.labelLarge),
        ),
        const SizedBox(height: 8),
        Semantics(
          button: true,
          enabled: _enabled,
          label: widget.label,
          value: displayState == LinnState.idle
              ? dateText
              : '$dateText, ${displayState.label}',
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: _enabled ? () => _pick(context) : null,
              borderRadius: LinnStyle.radius(context),
              onFocusChange: (focused) => setState(() => _focused = focused),
              child: ExcludeSemantics(
                child: InputDecorator(
                  isFocused: _focused && _enabled,
                  decoration: InputDecoration(
                    enabled: _enabled,
                    border: border,
                    enabledBorder: border,
                    disabledBorder: border,
                    focusedBorder: border,
                    contentPadding:
                        widget.contentPadding ??
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                    suffixIcon: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (displayState != LinnState.idle && !disabled)
                            LinnStateIndicator(
                              state: displayState,
                              color: accent,
                            ),
                          if (displayState != LinnState.loading) ...[
                            if (hasError || displayState == LinnState.success)
                              const SizedBox(width: 8),
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 20,
                              color: scheme.onSurfaceVariant,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  child: Text(
                    dateText,
                    style:
                        theme.textTheme.bodyMedium
                            ?.copyWith(
                              color: value == null || disabled
                                  ? scheme.onSurfaceVariant
                                  : scheme.onSurface,
                            )
                            .merge(widget.textStyle) ??
                        widget.textStyle,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (feedback != null) ...[
          const SizedBox(height: 6),
          Semantics(
            liveRegion: hasError,
            child: Text(
              feedback,
              style: theme.textTheme.bodySmall?.copyWith(
                color: hasError || displayState == LinnState.success
                    ? accent
                    : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
