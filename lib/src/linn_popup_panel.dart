import 'package:flutter/material.dart';

import 'linn_state.dart';
import 'linn_style.dart';

/// Shared Material dialog surface for Linn alerts, confirmations and details.
class LinnPopupPanel extends StatelessWidget {
  const LinnPopupPanel({
    required this.title,
    required this.actions,
    this.content,
    this.icon,
    this.state = LinnState.idle,
    super.key,
  });

  final String title;
  final Widget? content;
  final IconData? icon;
  final LinnState state;
  final List<Widget> actions;

  static ButtonStyle secondaryButton(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton.styleFrom(
      foregroundColor: scheme.onSurface,
      minimumSize: const Size(72, 44),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      side: BorderSide(color: scheme.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: LinnStyle.radius(context)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = LinnStyle.accent(context, state);
    return AlertDialog(
      constraints: const BoxConstraints.tightFor(width: 420),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 10,
      shape: LinnStyle.popupShape(context),
      clipBehavior: Clip.antiAlias,
      scrollable: true,
      titlePadding: EdgeInsets.fromLTRB(24, 24, 24, content == null ? 20 : 0),
      titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinnFeedbackIcon(state: state, color: accent, icon: icon, size: 42),
          const SizedBox(height: 14),
          Semantics(
            value: state == LinnState.idle ? null : state.label,
            child: Text(title),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      contentTextStyle: theme.textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
        height: 1.55,
      ),
      content: content,
      actionsPadding: EdgeInsets.zero,
      actions: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          child: OverflowBar(
            alignment: MainAxisAlignment.end,
            spacing: 8,
            overflowSpacing: 8,
            overflowAlignment: OverflowBarAlignment.end,
            children: actions,
          ),
        ),
      ],
    );
  }
}
