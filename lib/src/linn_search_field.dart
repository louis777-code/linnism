import 'package:flutter/material.dart';

import 'linn_icon_button.dart';
import 'linn_state.dart';
import 'linn_theme.dart';
import 'linn_text_field.dart';

/// A search input that reports edits and provides a clear button.
///
/// Supply [controller] when the app needs to read or clear the query directly.
/// Loading and disabled preserve the query and block editing.
class LinnSearchField extends StatefulWidget {
  const LinnSearchField({
    this.label = 'Search',
    this.hintText = 'Enter a search term',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.state = LinnState.idle,
    this.message,
    this.style,
    this.contentPadding,
    this.textStyle,
    super.key,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final LinnState state;
  final LinnThemeData? style;
  final String? message;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;

  @override
  State<LinnSearchField> createState() => _LinnSearchFieldState();
}

class _LinnSearchFieldState extends State<LinnSearchField> {
  TextEditingController? _ownedController;

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        widget.controller ?? (_ownedController ??= TextEditingController());
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, value, _) => LinnTextField(
        label: widget.label,
        hintText: widget.hintText,
        controller: controller,
        message: widget.message,
        state: widget.state,
        style: widget.style,
        contentPadding: widget.contentPadding,
        textStyle: widget.textStyle,
        textInputAction: TextInputAction.search,
        onChanged: widget.onChanged,
        onSubmitted: widget.state.isInteractive ? widget.onSubmitted : null,
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: value.text.isNotEmpty && widget.state.isInteractive
            ? Padding(
                padding: const EdgeInsetsDirectional.only(end: 4),
                child: LinnIconButton(
                  label: 'Clear search',
                  icon: Icons.close_rounded,
                  onPressed: () {
                    controller.clear();
                    widget.onChanged?.call('');
                  },
                ),
              )
            : null,
      ),
    );
  }
}
