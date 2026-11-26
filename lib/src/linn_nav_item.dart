import 'package:flutter/material.dart';

import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// A sidebar destination with optional selection and operation feedback.
///
/// The caller owns navigation and [selected]. Loading and disabled prevent
/// activation while preserving the current selection.
class LinnNavItem extends StatelessWidget {
  const LinnNavItem({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.selected = false,
    this.state = LinnState.idle,
    this.style,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool selected;
  final LinnState state;
  final LinnThemeData? style;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = state.isInteractive && onPressed != null;
    final disabled = !enabled && state != LinnState.loading;
    final accent = LinnStyle.accent(
      context,
      disabled ? LinnState.disabled : state,
    );
    final color = selected || disabled ? accent : scheme.onSurface;

    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      value: disabled ? LinnState.disabled.label : state.label,
      child: Material(
        color: selected
            ? Color.alphaBlend(accent.withValues(alpha: 0.12), scheme.surface)
            : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: LinnStyle.radius(context),
          side: selected ? BorderSide(color: accent) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: color,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (state != LinnState.idle &&
                      state != LinnState.disabled) ...[
                    const SizedBox(width: 12),
                    ExcludeSemantics(
                      child: LinnStateIndicator(state: state, color: accent),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
