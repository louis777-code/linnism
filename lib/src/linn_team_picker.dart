import 'package:flutter/material.dart';

import 'linn_dropdown.dart';
import 'linn_state.dart';
import 'linn_theme.dart';

/// Selects a team from a map of stable IDs to display names.
class LinnTeamPicker extends StatelessWidget {
  const LinnTeamPicker({
    required this.teams,
    required this.onChanged,
    this.value,
    this.label = 'Assign team',
    this.state = LinnState.idle,
    this.message,
    this.validator,
    this.style,
    super.key,
  });

  final Map<String, String> teams;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String label;
  final LinnState state;
  final LinnThemeData? style;
  final String? message;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) => LinnDropdown<String>(
    label: label,
    items: teams.keys.toList(),
    itemLabel: (id) => teams[id]!,
    value: teams.containsKey(value) ? value : null,
    hintText: 'Choose a team',
    onChanged: onChanged,
    state: state,
    style: style,
    message: message,
    validator: validator,
  );
}
